package WRRA;
use Mojo::Base 'Mojolicious';

use Carp;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Mojo::Util qw(decamelize);

# This method will run once at server start
sub startup {
	my $self = shift;
	$self = $self->moniker('wrra');
	$Carp::Verbose = 1;
	$self->setup_plugins;
	$self->setup_routing;

	$self->helper(year => sub { shift->db->year(@_) });
	$self->hook(before_dispatch => sub {
		my $c = shift;
		#warn Data::Dumper::Dumper([$c->session->{year}, $ENV{WRRA_YEAR}, $c->config]);
		$c->year($c->session->{year} || $ENV{WRRA_YEAR} || $c->config->{year});
	});
}

sub setup_plugins {
	my $self = shift;

	#$self->plugin('PODRenderer');  # Documentation browser under "/perldoc"
	#$self->plugin('ConsoleLogger');  # Only use on HTML docs
	$self->plugin('Config');
	$self->plugin('MyConfig');
	$self->plugin('MyProcess');
	$self->plugin(DBIC => (schema => 'WRRA::Schema'));
	$self->plugin(TitleTag => {tag => sub { join(' - ', $_[0]->db->year, $_[0]->config('version')) }});
	$self->plugin(LogRequests => {tag => sub { shift->db->year }});
	$self->plugin('WriteExcel');
	$self->plugin('HeaderCondition');
	$self->plugin('AutoComplete');
	$self->plugin('IsXHR');

	#$self->plugin('I18N' => { default => 'en'});  # Helper "url_for" already exists, replacing

	# Add types for responding_to a specific accept type
	$self->types->type(jqgrid => 'x-application/jqgrid');
}

sub setup_routing {
	my $self = shift;
	my $r = $self->routes;

	# Authentication conditions
	$r->add_condition(login => sub { $_[1]->auth_require_login });
	$r->add_condition(role  => sub { $_[1]->auth_require_role($_[3]) });

	# Shortcuts
	$r->add_shortcut(xhr => sub { shift->over(is_xhr=>shift||1) });
	$r->add_shortcut(jqgrid => sub {
		my $r = shift;
		my ($view, $source) = (undef, undef);
		foreach ( @_ ) {
			($view, $source) = @$_ if ref $_ eq 'ARRAY';
		}
		my $name = decamelize($view) or return undef;
		my $r1 = $r->under("/$name");
		$r1->view([$view => $source], {jqgrid => 'create'});
		$r1->view([$view => $source], {jqgrid => 'read'}, name => '');
		$r1->view([$view => $source], {jqgrid => 'update'});
		$r1->view([$view => $source], {jqgrid => 'delete'});
	});
	$r->add_shortcut(auto_complete => sub {
		my $r = shift;
		my ($view, $source) = (undef, undef);
		foreach ( @_ ) {
			($view, $source) = @$_ if ref $_ eq 'ARRAY';
		}
		my $name = decamelize($view) or return undef;
		$r->view(["Ac$view", $source], {api => 'auto_complete'}, name => $view);
	});
	$r->add_shortcut(build_select => sub {
		my $r = shift;
		my ($view, $source) = (undef, undef);
		foreach ( @_ ) {
			($view, $source) = @$_ if ref $_ eq 'ARRAY';
		}
		my $name = decamelize($view) or return undef;
		$r->view(["Bs$view", $source], {api => 'build_select'}, name => $view);
	});
	$r->add_shortcut(view => sub {
		my $r = shift;
		my ($view, $source, $method, $controller, $action) = (undef, undef, 'post', 'crud', 'read');
		foreach ( @_ ) {
			($controller, $action) = %$_ if ref $_ eq 'HASH';
			($view, $source) = @$_ if ref $_ eq 'ARRAY';
			($method) = $$_ if ref $_ eq 'SCALAR';
		}
		%_ = grep { !ref } @_;
		my $name = delete $_{name} // $view || $action;
		$name = decamelize($name);
		my $extra_path = delete $_{extra_path};
		$r->$method(join('/', '', grep { $_ } $name, $extra_path))->xhr->to("$controller#$action", results=>[$view, $source], %_)->name(join('_', $controller, $action, grep { $_ } $name, $extra_path));
		#$r1->get("/$name.xls")->to('crud#read', m=>"$name", v=>'jqgrid', format=>'xls')->name($name);
	});

	# Normal route to controller
	$r->get('/')->to('user#index');
	$r->post('/' => sub { my $self = shift; $self->render_json($self->req->json); });
	$r->get('/bookmarks')->to(cb=>sub{shift->redirect_to('/admin/bookmarks')});

	my $api = $r->under('/api');

	my $ac = $api->under('/ac');
	$ac->auto_complete([City => 'Donor']);
	$ac->auto_complete(['Donor']);
	$ac->auto_complete(['Item']);
	$ac->auto_complete([ItemCurrent => 'Item']);
	$ac->auto_complete(['Stockitem']);
	$ac->auto_complete([Advertisement => 'Donor']);
	$ac->auto_complete([Advertiser => 'Donor']);
	$ac->auto_complete([ItemStockitem => 'Item']);
	$ac->auto_complete(['Bellitem']);
	$ac->auto_complete(['Bidder']);
	$ac->auto_complete(['Ad']);
	#$ac->get("/$model")->xhr->to("api#auto_complete", mv=>"ac_$model")->name("ac_$model") foreach my $model ( qw/city donor item item_current stockitem advertisement advertiser item_stockitem bellitem bidder ad/ );

	my $bs = $api->under('/bs');
	$bs->build_select([Rotarians => 'Rotarian']);
	#$bs->get("/$model")->xhr->to("api#build_select", mv=>"bs_$model")->name("bs_$model") foreach my $model ( qw/rotarians/ );

	$api->view([ItemNumber => 'Item'], {api => 'item_number'});
	#$api->get('/item_number')->xhr->to('api#item_number', mv=>'item_number')->name('item_number');

	my $admin = $r->under('/admin');
	$admin->jqgrid([Rotarians => 'Rotarian']);
	$admin->jqgrid([Donors => 'Donor']);
	$admin->under('/donors')->view([DonorItems => 'Item'], {jqgrid => 'read'});
	$admin->jqgrid([Stockitems => 'Stockitem']);
	$admin->jqgrid([Items => 'Item']);
	$admin->jqgrid([Ads => 'Ad']);
	$admin->jqgrid([Bellitems => 'Bellitem']);
	$admin->jqgrid([Bidders => 'Bidder']);
	$admin->jqgrid([Bids => 'Bid']);
	$admin->view([SeqItems => 'Item'], \'get');
	$admin->view([SeqItems => 'Item'], \'get', extra_path => ':n');
	$admin->view([SeqItems => 'Item'], {crud => 'update'}, \'post', extra_path => ':n');

	my $reports = $admin->under('/reports');
	$reports->view([Postcards => 'Item']);
	$reports->view([Flyer => 'Item']);
	$reports->view([Bankreport => 'Item']);
	$reports->view([Summary => 'Item']);
	$reports->view([Stockreport => 'Stockitem']);
	$reports->view([Winners => 'Item']);

	my $sol_aids = $admin->under('/solicitation_aids');
	$sol_aids->get('/checklist')->xhr->to('crud#read', m=>'checklist', v=>'checklist');
	$sol_aids->get('/packets')->xhr->to('crud#read', m=>'packets', v=>'packets');
	$sol_aids->get('/packet/:id', id=>qr/\d+/)->xhr->to('crud#read', m=>'packet', v=>'packet');

	# Although this is a plugin, it's an autorouter, so it needs to be last
	# Routes are handled by first match
	$self->plugin('AutoRoute', {route => $self->routes});
}

1;
