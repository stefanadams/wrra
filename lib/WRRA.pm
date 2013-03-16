package WRRA;
use Mojo::Base 'Mojolicious';

use List::MoreUtils qw(firstidx);

# This method will run once at server start
sub startup {
	my $self = shift;

	$self->plugin('Profiler');

	$self = $self->moniker('wrra');
	$self->secret($ENV{MOJO_SECRET} || $self->config->{secret} || __PACKAGE__);

	$self->plugin('Config');
	$self->plugin('DateTime');
	$self->plugin('Version');
	$self->plugin('Hypnotoad');
	$self->plugin('Memcached' => {username => sub { shift->username }});
	$self->plugin('PoweredBy' => (name => $self->config->{powered_by})) if $self->config->{powered_by};
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
        #groups => {
        #        #group => [qw/user names/],
        #        admins => [qw/admin/],
        #        adsales => [qw/adsales :admins/],
        #        callers => [qw/caller :admins/],
        #        bellringers => [qw/bellringer :admins/],
        #        auctioneers => [qw/a b auctioneer :admins/],
        #        operators => [qw/operator :admins/],
        #        backend => [qw/:admins :auctioneers :operators/],
        #},
	$self->plugin('authorization', {
		has_priv => sub { # ->has_privilege('privilege')  =>  t/f if supplied priv is in list of user's privs
			my ($c, $priv, $extradata) = @_;
			return 0 unless $c->is_user_authenticated;
			return 0 unless $c->config->{groups};
			return $c->privileges->{$priv};
		},
		is_role => sub { # ->is('role')  =>  t/f if supplied role is user's role
			my ($c, $role, $extradata) = @_;
			return 0 unless $c->is_user_authenticated;
			return 1 if $c->current_user->{username} eq $role;
			foreach ( keys %{$c->config->{groups}} ) {
				return 1 if grep { $c->current_user->{username} eq $_ } @{$c->config->{groups}->{$_}};
			}
			return 0;
		},
		user_privs => sub { # ->privileges;  =>  (admins, auctioneers, ...)
			my ($c, $extradata) = @_;
			return undef unless $c->is_user_authenticated;
			return undef unless $c->current_user;
			return undef unless $c->current_user->{username};
			return undef unless $c->config->{groups};
			my %privs = (
				admin => [qw/admins adsales callers bellringers auctioneers operators backend/],
				adsales => [qw/adsales/],
				caller => [qw/callers/],
				bellringer => [qw/bellringers/],
				auctioneer => [qw/auctioneers backend/],
				a => [qw/auctioneers backend/],
				b => [qw/auctioneers backend/],
				operator => [qw/operators backend/],
			);
			return undef unless $privs{$c->current_user->{username}};
			return {map { $_ => 1 } @{$privs{$c->current_user->{username}}}};
		},
		user_role => sub { # ->role;  =>  admins or auctioneers or ...
			my ($c, $extradata) = @_;
			return undef unless $c->is_user_authenticated;
			return undef unless $c->config->{groups};
			my $groups = $c->config->{groups};
			foreach my $g ( keys %$groups ) {
				my ($role) = grep { $c->current_user->{username} eq $_ } @{$groups->{$g}} or next;
				return $g
			}
			return $c->current_user->{username};
		},
	});

	$self->setup_routing;

	$self->plugin('AutoRoute', {route => $self->routes});
}

#sub _expand_group {
#        my ($groups, $group) = @_;
#
#	my %groups = %$groups;
#        $group =~ s/^://;
#        push @{$groups{$group}}, _expand_group({%groups}, $_) foreach grep { /^:/ } @{$groups{$group}};
#        return grep { /^(?!:)/ } @{$groups{$group}};
#}

sub setup_routing {
	my $self = shift;
	my $r = $self->routes;

	$r->get('/profiler')->to(cb=>sub{shift->render_text('ok')});

	# Normal route to controller
	$r->get('/')->xhr(0)->to(template => '/auction')->name('index');
	my $auction = $r->under('/auction')->xhr;
	$auction->get('/')->to('auction#auction')->name('auction');
	$auction->post('/start')->over(has_priv=>'auctioneers')->to('auction#start');
	$auction->post('/timer/:timer', timer=>[qw/start stop/])->over(has_priv=>'auctioneers')->to('auction#timer')->name('timer');
	$auction->post('/sell')->over(has_priv=>'auctioneers')->to('auction#sell');
	$auction->post('/bid')->to('auction#bid');
	$auction->post('/bidder')->to('auction#bidder');

	#$auction->post('/assign/:id/:auctioneer')->over(has_priv=>'admins')->to('auction#assign');
	#$auction->post('/start/:id')->over(has_priv=>'auctioneers')->to('auction#start');
	#$auction->post('/notify/:notify/:id/:state', notify=>[qw/starttimer stoptimer holdover sell/])->over(has_priv=>'auctioneers')->to('auction#notify');
	#$auction->post('/sell/:id')->over(has_priv=>'auctioneers')->to('auction#sell');
	#$auction->post('/starttimer/:id')->over(has_priv=>'auctioneers')->to('auction#timer', timer=>1);
	#$auction->post('/stoptimer/:id')->over(has_priv=>'auctioneers')->to('auction#timer', timer=>0);
	#$auction->post('/respond/:id', notify=>[qw/starttimer stoptimer holdover sell/])->over(has_priv=>'auctioneers')->to('auction#notify');
	#$auction->any("/$_")->name($_) for qw/start assign notify sell starttimer stoptimer bid bidder/;

	$r->any('/register')->to('auth#register');
	$r->any('/login')->to('auth#Login');
	$r->any('/logout')->to('auth#Logout');

	$r->get('/ad/:id')->to('ad#ad');
	$r->get('/ad')->name('ad');

	$r->get('/alert/:alert', {alert=>undef})->to('alert#alert');
	$r->post('/alert/:alert', {alert=>undef})->over(has_priv=>'admins')->to('alert#alert');
	$r->delete('/alert/:alert', {alert=>undef})->over(has_priv=>'admins')->to('alert#alert');
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
	my $admin = $r->under('/admin')->over(has_priv=>'admins');
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
