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

	# Normal route to controller
	$r->get('/')->to('user#index');
	$r->post('/' => sub { my $self = shift; $self->render_json($self->req->json); });
	$r->get('/bookmarks')->to(cb=>sub{shift->redirect_to('/admin/bookmarks')});

	my $api = $r->under('/api');

	my $ac = $api->under('/ac');
	foreach my $model ( qw/city donor item item_current stockitem advertisement advertiser item_stockitem bellitem bidder ad/ ) {
		$ac->get("/$model")->xhr->to("api#auto_complete", mv=>"ac_$model")->name("ac_$model");
	}
	my $bs = $api->under('/bs');
	foreach my $model ( qw/rotarians/ ) {
		$bs->get("/$model")->xhr->to("api#build_select", mv=>"bs_$model")->name("bs_$model");
	}
	my $item_number = $api->get('/item_number')->xhr->to('api#item_number', mv=>'item_number')->name('item_number');

	my $admin = $r->under('/admin');

	foreach (
		[Rotarians => 'Rotarian'],
		[Donors => 'Donor'],
		[Stockitems => 'Stockitem'],
		[Items => 'Item'],
		[Ads => 'Ad'],
		[Bellitems => 'Bellitem'],
		[Bidders => 'Bidder'],
		[Bids => 'Bid'],
	) {
		my $name = decamelize($_->[0]);
		my $r1 = $admin->under("/$name");
		$r1->post("/create")->xhr->to("crud#create", m=>$name, v=>'jqgrid')->name('create_'.$name);
		$r1->post('/')->xhr->to('jqgrid#read', results=>$_)->name($name);
		#$r1->get('/', format=>[qw/xls/])->to('crud#read', m=>$name, v=>'jqgrid'); # Why won't this work?
		$admin->get("/$name.xls")->to('crud#read', m=>$name, v=>'jqgrid', format=>'xls'); # Can only download via a non-xhr get request
		$r1->post("/update")->xhr->to("crud#update", m=>$name, v=>'jqgrid')->name('update_'.$name);
		$r1->delete("/delete")->xhr->to("crud#delete", m=>$name, v=>'jqgrid')->name('delete_'.$name);
	}
	$admin->under('/donors')->post('/items')->xhr->to('crud#read', m=>'donor_items', v=>'jqgrid')->name('donor_items');
	$admin->get('/sequence')->xhr->to('crud#read', m=>'seq_items', v=>'seq_items', start=>$self->app->config('start'))->name('seq_items');
	$admin->get('/sequence/:n')->xhr->to('crud#read', m=>'seq_items', v=>'seq_items', start=>$self->app->config('start'));
	$admin->post('/sequence/:n')->xhr->to('crud#update', m=>'seq_items', v=>'seq_items', start=>$self->app->config('start'));

	my $reports = $admin->under('/reports');

	foreach my $name ( qw/postcards flyer bankreport summary stockreport winners/ ) {
		$reports->post("/$name")->xhr->to('crud#read', m=>"$name", v=>'jqgrid');
		$reports->get("/$name.xls")->to('crud#read', m=>"$name", v=>'jqgrid', format=>'xls')->name($name);
	}

	my $sol_aids = $admin->under('/solicitation_aids');
	$sol_aids->get('/checklist')->xhr->to('crud#read', m=>'checklist', v=>'checklist');
	$sol_aids->get('/packets')->xhr->to('crud#read', m=>'packets', v=>'packets');
	$sol_aids->get('/packet/:id', id=>qr/\d+/)->xhr->to('crud#read', m=>'packet', v=>'packet');

	# Although this is a plugin, it's an autorouter, so it needs to be last
	# Routes are handled by first match
	$self->plugin('AutoRoute', {route => $self->routes});
}

1;
