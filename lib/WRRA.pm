package WRRA;
use Mojo::Base 'Mojolicious';

use List::MoreUtils qw(firstidx);

# This method will run once at server start
sub startup {
	my $self = shift;

	$self = $self->moniker('wrra');

	$self->plugin('Config');
	$self->plugin('DateTime');
	$self->plugin('Version');
	$self->plugin('Hypnotoad');
	$self->plugin('MergedParams');
	$self->plugin('MergePostdata' => {'application/json' => sub { shift->req->json }});
	$self->plugin('DBIC' => {schema => 'WRRA::Schema'});
	$self->plugin('TitleTag' => {tag => sub { join(' - ', $_[0]->datetime->year, $_[0]->config('version'), $_[0]->config('database')->{name}) }});
	$self->plugin('LogRequests' => {tag => sub { shift->datetime->year }});
	$self->plugin('WriteExcel');
	$self->plugin('HeaderCondition');
	$self->plugin('XHR');
	$self->plugin('AutoComplete');
	$self->plugin('BuildSelect');
	$self->plugin('Jqgrid');
	$self->plugin('WRRA');
	$self->plugin('authentication' => {
		'autoload_user' => 1,
		'session_key' => 'fifdhiwfiwhgfyug38g3iuhe8923oij20',
		'load_user' => sub {
			my ($c, $username) = @_;
			if ( exists $c->config->{users}->{$username} ) {
				return {username=>$username,name=>$username};
			} else {
				my $r = $c->db->resultset('Bidder')->current_year->find({username=>$username});
				return {username=>$r->username, name=>$r->name};
			}
			return undef;
		},
		'validate_user' => sub {
			my ($c, $username, $password, $extradata) = @_;
			return undef unless defined $username;
			if ( exists $c->config->{users}->{$username} ) {
				return $username if $password eq $c->config->{users}->{$username};
			} else {
				return $username if $c->db->resultset('Bidder')->current_year->find({username=>$username, phone=>$password});
			}
			return undef;
		},
	});
	$self->plugin('authorization', {
		has_priv => sub {
			my ($c, $priv, $extradata) = @_;
			return 0 unless $c->is_user_authenticated;
			return 0 unless $c->config->{groups};
                        return 1 if $c->current_user->{username} eq $priv || grep { $_ eq $c->current_user->{username} } _expand_group($c->config->{groups}, $priv);
			return 0;
		},
		is_role => sub {
			my ($c, $role, $extradata) = @_;
			return 0 unless $c->is_user_authenticated;
			return 0 unless $c->config->{groups};
                        return 1 if $c->current_user->{username} eq $role || grep { $_ eq $c->current_user->{username} } _expand_group($c->config->{groups}, $role);
			return 0;
		},
		user_privs => sub {
			my ($c, $extradata) = @_;
			return undef unless $c->is_user_authenticated;
			return $c->current_user->{username};
		},
		user_role => sub {
			my ($c, $extradata) = @_;
			return undef unless $c->is_user_authenticated;
			return $c->current_user->{username};
		},
	});

	$self->setup_routing;

	$self->plugin('AutoRoute', {route => $self->routes});
}

sub _expand_group {
        my ($groups, $group) = @_;

        my %groups = %$groups;
        $group =~ s/^://;
        push @{$groups{$group}}, _expand_group(\%groups, $_) foreach grep { /^:/ } @{$groups{$group}};
        return grep { /^(?!:)/ } @{$groups{$group}};
}

sub setup_routing {
	my $self = shift;
	my $r = $self->routes;

	# Normal route to controller
	$r->get('/')->xhr(0)->to(template => '/auction')->name('index');
	my $auction = $r->under('/auction')->xhr;
	$auction->get('/')->to('auction#items', Status=>'Bidding')->name('auction');
	$auction->post('/assign/:id/:auctioneer')->over(has_priv=>'admin')->to('auction#assign');
	$auction->post('/notify/:notify/:id', notify=>[qw/starttimer stoptimer holdover sell/])->over(has_priv=>'admin')->to('auction#notify');
	$auction->post('/sell/:id')->over(has_priv=>'auctioneer')->to('auction#sell');
	$auction->post('/starttimer/:id')->over(has_priv=>'auctioneer')->to('auction#timer', timer=>1);
	$auction->post('/stoptimer/:id')->over(has_priv=>'auctioneer')->to('auction#timer', timer=>0);
	$auction->post('/bid/:id' => {id=>undef})->over(has_priv=>'operator')->to('auction#bid');
	$auction->get("/$_")->name($_) for qw/assign notify sell starttimer stoptimer bid/;

	$r->any('/register')->to('auth#register');
	$r->any('/login')->to('auth#Login');
	$r->any('/logout')->to('auth#Logout');

	$r->get('/ad/:id')->to('ad#ad');
	$r->get('/ad')->name('ad');

	$r->get('/alert/:alert', {alert=>undef})->to('alert#alert')->name('alert');
	$r->post('/alert/:alert', {alert=>undef})->over(has_priv=>'admin')->to('alert#alert');
	$r->delete('/alert/:alert', {alert=>undef})->over(has_priv=>'admin')->to('alert#alert');
	$r->get('/alert')->name('alert');

	my $api = $r->under('/api');
	my $ac = $api->under('/ac');
	$ac->auto_complete([City => 'Donor']);
	$ac->auto_complete(['Donor']);
	$ac->auto_complete(['Item']);
	$ac->auto_complete([ItemCurrent => 'Item']);
	$ac->auto_complete(['Stockitem']);
	$ac->auto_complete([Advertisement => 'Donor']);
	$ac->auto_complete([Advertiser => 'Ad']);
	$ac->auto_complete([ItemStockitem => 'Item']);
	$ac->auto_complete(['Bellitem']);
	$ac->auto_complete(['Bidder']);
	$ac->auto_complete(['Ad']);
	$ac->auto_complete([PayNumber => 'Item']);
	my $bs = $api->under('/bs');
	$bs->build_select([Rotarians => 'Rotarian']);

	$r->get('/bookmarks')->to(cb=>sub{shift->redirect_to('/admin/bookmarks')});
	my $admin = $r->under('/admin')->over(has_priv=>'admin');
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

	#my $sol_aids = $admin->under('/solicitation_aids');
	#$sol_aids->get('/checklist')->xhr->to('crud#read', m=>'checklist', v=>'checklist');
	#$sol_aids->get('/packets')->xhr->to('crud#read', m=>'packets', v=>'packets');
	#$sol_aids->get('/packet/:id', id=>qr/\d+/)->xhr->to('crud#read', m=>'packet', v=>'packet');
}

1;
