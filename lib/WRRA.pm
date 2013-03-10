package WRRA;
use Mojo::Base 'Mojolicious';

use DateTime;

# This method will run once at server start
sub startup {
	my $self = shift;

	$self = $self->moniker('wrra');

	my $now = $ENV{WRRA_NOW} || $self->config->{now} || $self->session->{now};
	$now = $now || DateTime->now;

	$self->plugin('Config');
	$self->config(year => $now->year);
	$self->plugin('Version');
	$self->plugin('Hypnotoad');
	$self->plugin('MergedParams');
	$self->plugin('MergePostdata' => {'application/json' => sub { shift->req->json }});
	$self->plugin('DBIC' => {schema => 'WRRA::Schema'});
	$self->plugin('TitleTag' => {tag => sub { join(' - ', $_[0]->db->session->{year}, $_[0]->config('version'), $_[0]->config('database')->{name}) }});
	$self->plugin('LogRequests' => {tag => sub { shift->db->session->{year} }});
	$self->plugin('WriteExcel');
	$self->plugin('HeaderCondition');
	$self->plugin('XHR');
	$self->plugin('AutoComplete');
	$self->plugin('BuildSelect');
	$self->plugin('Jqgrid');

	$self->helper(dates => sub {
		my $c = shift;
		my @d1 = split /-/, $c->config->{auctions}->{$now->year}->[0];
		my @d2 = split /-/, $c->config->{auctions}->{$now->year}->[1];
		my $d1 = DateTime->new(month => $d1[1], day => $d1[2], year => $d1[0]);
		my $d2 = DateTime->new(month => $d2[1], day => $d2[2], year => $d2[0]);
		my @dates;
		while ($d1 <= $d2) {
			push @dates, $d1;
			$d1->add(days => 1);
		}
		return @dates;
	});
	$self->helper(closed => sub {
		my $c = shift;
		my @t1 = split /:/, $c->config->{hours}->{$now->year}->[0];
		my @t2 = split /:/, $c->config->{hours}->{$now->year}->[1];
		my $t1 = DateTime->new(month => $now->month, day => $now->day, year => $now->year, hour => $t1[0], minute => $t1[1], second => $t1[2]);
		my $t2 = DateTime->new(month => $now->month, day => $now->day, year => $now->year, hour => $t2[0], minute => $t2[1], second => $t2[2]);
		return 0 if $now >= $t1 && $now <= $t2;
	});

	$self->setup_routing;

	$self->plugin('AutoRoute', {route => $self->routes});
}

sub setup_routing {
	my $self = shift;
	my $r = $self->routes;

	# Authentication conditions
	$r->add_condition(login => sub { $_[1]->auth_require_login });
	$r->add_condition(role  => sub { $_[1]->auth_require_role($_[3]) });

	# Normal route to controller
	$r->get('/')->to(template => '/bidding');
	$r->dbroute(['/' => Bidding => 'Item'], {bidding => 'read'}, \'post');
	$r->post('/' => sub { my $self = shift; $self->req->body_size ? $self->render_json($self->req->json) : $self->render_text('no_json'); });
	$r->get('/bookmarks')->to(cb=>sub{shift->redirect_to('/admin/bookmarks')});

	my $api = $r->under('/api');
	$api->any('/alert')->to('api#alert');
	$api->get('/ad/:id')->to('api#ad');
	$api->get('/header')->to('api#header');
	my $config = $api->under('/dbconfig');
	$config->get('/year/:year', {year=>undef})->to('api#api_dbconfig', config=>'year');
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
	my $bs = $api->under('/bs');
	$bs->build_select([Rotarians => 'Rotarian']);

	my $admin = $r->under('/admin');
	$admin->jqgrid([Rotarians => 'Rotarian']);
	$admin->jqgrid([Donors => 'Donor'])->dbroute(['/items' => DonorItems => 'Item'], {jqgrid => 'read'});
	$admin->jqgrid([Stockitems => 'Stockitem']);
	$admin->jqgrid([Items => 'Item']);
	$admin->jqgrid([Ads => 'Ad']);
	$admin->jqgrid([Bellitems => 'Bellitem']);
	$admin->jqgrid([Bidders => 'Bidder']);
	$admin->jqgrid([Bids => 'Bid']);
	$admin->under('/seq_items')
		->dbroute(['/' => SeqItems => 'Item'], {seq_items => 'list'}, \'get', extra_path => ':n')
		->dbroute(['/' => SeqItems => 'Item'], {seq_items => 'sequence'}, \'post', extra_path => ':n');

	my $reports = $admin->under('/reports');
	$reports->jqgrid_ro([Postcards => 'Donor']);
	$reports->jqgrid_ro([Flyer => 'Item']);
	$reports->jqgrid_ro([Bankreport => 'Item']);
	$reports->jqgrid_ro([Summary => 'Item']);
	$reports->jqgrid_ro([Stockreport => 'Stockitem']);
	$reports->jqgrid_ro([Winners => 'Item']);

	my $sol_aids = $admin->under('/solicitation_aids');
	$sol_aids->get('/checklist')->xhr->to('crud#read', m=>'checklist', v=>'checklist');
	$sol_aids->get('/packets')->xhr->to('crud#read', m=>'packets', v=>'packets');
	$sol_aids->get('/packet/:id', id=>qr/\d+/)->xhr->to('crud#read', m=>'packet', v=>'packet');
}

1;
