package WRRA;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
	my $self = shift;

	$self = $self->moniker('wrra');

	$self->plugin('Config');
	$self->plugin('Version');
	$self->plugin('Hypnotoad');
	$self->plugin('MergedParams');
	$self->plugin('DBIC' => {schema => 'WRRA::Schema'});
	$self->plugin('TitleTag' => {tag => sub { join(' - ', $_[0]->db->session->{year}, $_[0]->config('version')) }});
	$self->plugin('LogRequests' => {tag => sub { shift->db->session->{year} }});
	$self->plugin('WriteExcel');
	$self->plugin('HeaderCondition');
	$self->plugin('XHR');
	$self->plugin('AutoComplete');
	$self->plugin('BuildSelect');
	$self->plugin('Jqgrid');

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
	$r->get('/')->to('index#current_bidding');
	$r->post('/' => sub { my $self = shift; $self->req->body_size ? $self->render_json($self->req->json) : $self->render_text('no_json'); });
	$r->get('/bookmarks')->to(cb=>sub{shift->redirect_to('/admin/bookmarks')});

	my $api = $r->under('/api');
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
	#$ac->get("/$model")->xhr->to("api#auto_complete", mv=>"ac_$model")->name("ac_$model") foreach my $model ( qw/city donor item item_current stockitem advertisement advertiser item_stockitem bellitem bidder ad/ );
	my $bs = $api->under('/bs');
	$bs->build_select([Rotarians => 'Rotarian']);
	#$bs->get("/$model")->xhr->to("api#build_select", mv=>"bs_$model")->name("bs_$model") foreach my $model ( qw/rotarians/ );
	$api->dbroute([ItemNumber => 'Item'], {api => 'item_number'});
	#$api->get('/item_number')->xhr->to('api#item_number', mv=>'item_number')->name('item_number');

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
		->dbroute(['/' => SeqItems => 'Item'], \'get')
		->dbroute(['/' => SeqItems => 'Item'], \'get', extra_path => ':n')
		->dbroute(['/' => SeqItems => 'Item'], {crud => 'update'}, \'post', extra_path => ':n');

	my $reports = $admin->under('/reports');
	$reports->dbroute([Postcards => 'Item'], {jqgrid => 'read'});
	$reports->dbroute([Flyer => 'Item'], {jqgrid => 'read'});
	$reports->dbroute([Bankreport => 'Item'], {jqgrid => 'read'});
	$reports->dbroute([Summary => 'Item'], {jqgrid => 'read'});
	$reports->dbroute([Stockreport => 'Stockitem'], {jqgrid => 'read'});
	$reports->dbroute([Winners => 'Item'], {jqgrid => 'read'});

	my $sol_aids = $admin->under('/solicitation_aids');
	$sol_aids->get('/checklist')->xhr->to('crud#read', m=>'checklist', v=>'checklist');
	$sol_aids->get('/packets')->xhr->to('crud#read', m=>'packets', v=>'packets');
	$sol_aids->get('/packet/:id', id=>qr/\d+/)->xhr->to('crud#read', m=>'packet', v=>'packet');
}

1;
