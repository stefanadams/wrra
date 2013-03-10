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

	$self->helper(dates => sub {
		my $c = shift;
		my $range = ref $_[0] ? $_[0] : [@_] if @_;
		$range ||= $c->config->{auctions}->{$c->datetime->year} or return ();
		my $d0 = $c->datetime($range->[0]);
		my $d1 = $c->datetime($range->[1]);
		my @dates;
		my $inc;
		while ($d0 <= $d1) {
			push @dates, $c->datetime($d0);
			$d0->add(days => 1);
			$inc++;
		}
		$d0->subtract(days => $inc);
#warn Data::Dumper::Dumper({dates=>[map { $_->ymd } @dates]});
		return wantarray ? @dates : [@dates];
	});
	$self->helper(years => sub {
		my $c = shift;
		my @years = grep { $_ >= $c->datetime->year } keys %{$c->config->{auctions}};
#warn Data::Dumper::Dumper({years=>[@years]});
		wantarray ? @years : [@years];
	});
	$self->helper(auctions => sub {
		my ($c, $year) = @_;
		$year ||= $c->years->[0];
		my @auctions = ();
		foreach my $_year ( $year || $c->years ) {
			next unless $c->config->{auctions}->{$year};
			@auctions = grep { $_ > $c->datetime } $c->dates($_year) and last;
		}
warn Data::Dumper::Dumper({auctions=>[map { $_->ymd } @auctions]});
		wantarray ? @auctions : [@auctions];
	});
	$self->helper(hours => sub {
		my ($c, $date) = @_;
		$date ||= $c->auctions($c->years->[0])->[0];
		my @hours = $c->config->{hours}->{$date->year}->{$date->ymd} ? @{$c->config->{hours}->{$date->year}->{$date->ymd}} : @{$c->config->{default_hours}};
		@hours = map { $c->datetime($date->ymd." $_") } @hours;
warn Data::Dumper::Dumper({hours=>[map { $_->datetime } @hours]});
		wantarray ? @hours : [@hours];
	});
	$self->helper(night => sub {
		my ($c, $night) = @_;
		$night = $night ? $c->datetime($night) : $c->datetime;
		return undef unless $night;
		$night = firstidx { $_->ymd eq $night->ymd } $c->auctions($night->year);
		$night = $night >= 0 ? $night : undef;
#warn Data::Dumper::Dumper({night=>$night});
		return $night;
	});
	$self->helper(date_next => sub {
		my $c = shift;
		my $date_next = $c->auctions($c->years->[0])->[0] || $c->auctions($c->years->[1])->[0];
warn Data::Dumper::Dumper({date_next=>$date_next->ymd});
		return $date_next;
	});
	$self->helper(closed => sub {
		my $c = shift;
		$c->config->{closed} and return $c->config->{closed};
		exists $c->stash->{closed} and return $c->stash->{closed};
		my $dt = $c->datetime;
		return 1 unless grep { $_ eq $dt->ymd } $c->dates;
		my $t0 = $c->datetime(join ' ', $dt->ymd, $c->config->{hours}->{$dt->year}->{$dt->ymd}->[0] ? $c->config->{hours}->{$dt->year}->{$dt->ymd}->[0] : $c->config->{default_hours}->[0] ? $c->config->{default_hours}->[0] : ());
		my $t1 = $c->datetime(join ' ', $dt->ymd, $c->config->{hours}->{$dt->year}->{$dt->ymd}->[1] ? $c->config->{hours}->{$dt->year}->{$dt->ymd}->[1] : $c->config->{default_hours}->[1] ? $c->config->{default_hours}->[1] : ());
		return $c->stash->{closed} = $dt >= $t0 && $dt <= $t1 ? 0 : 1;
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
