package Mojolicious::Plugin::WRRA;
use Mojo::Base 'Mojolicious::Plugin';

use List::MoreUtils qw(firstidx);

sub register {
	my ($self, $app, $conf) = @_;
	my $moniker = uc($app->moniker);

	$app->helper(username => sub {
		my $c = shift;
		return $c->is_user_authenticated ? $c->current_user->{username} : undef
	});
	$app->helper(years => sub {
		my ($c, $year) = shift;
		$year ||= $c->datetime->year;
		my @years = grep { $_ >= $year } keys %{$c->config->{auctions}};
		#warn Data::Dumper::Dumper({years=>[@years]});
		wantarray ? @years : [@years];
	});
	$app->helper(range => sub {
		my ($c, $range) = @_;
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
		#warn Data::Dumper::Dumper({range=>[map { $_->ymd } @dates]});
		return wantarray ? @dates : [@dates];
	});
	$app->helper(auctions => sub {
		my ($c, $year) = @_;   
		my $range = $c->config->{auctions}->{$c->years($year)->[0]} or return wantarray ? () : [];
		my @auctions = grep { $c->datetime < $c->hours($_->ymd)->[1] } $c->range($range);
		#warn Data::Dumper::Dumper({auctions=>[map { $_->ymd } @auctions]});
		return wantarray ? @auctions : [@auctions];
	});
	$app->helper(hours => sub {
		my ($c, $date) = @_;
		$date = $date ? $c->datetime($date) : $c->datetime or return wantarray ? () : [];
		my @hours = $c->config->{hours}->{$date->year}->{$date->ymd} ? @{$c->config->{hours}->{$date->year}->{$date->ymd}} : @{$c->config->{default_hours}};
		@hours = map { $c->datetime($date->ymd." $_") } @hours;
		#warn Data::Dumper::Dumper({hours=>[map { $_->datetime } @hours]});
		return wantarray ? @hours : [@hours];
	});

	$app->helper(date_next => sub {
		my $c = shift;
		return $c->config->{date_next} if defined $c->config->{date_next};
		my $date_next = $c->hours($c->auctions->[0])->[0] || $c->hours($c->auctions($c->years->[1])->[0])->[0] || $c->datetime($c->datetime)->add(years=>1);
		#warn Data::Dumper::Dumper({date_next=>defined $date_next ? $date_next->ymd : ''});
		return $date_next;
	});
	$app->helper(night => sub {
		my ($c, $date) = @_;
		return $c->config->{night} if defined $c->config->{night};
		$date = $date ? $c->datetime($date) : $c->datetime;
		return undef unless $date;
		my @auctions = $c->range($c->config->{auctions}->{$date->year});
		my $night = firstidx { $_->ymd eq $date->ymd } @auctions;
		$night = $night >= 0 ? $night + 1 : undef;
		#warn Data::Dumper::Dumper({night=>$night});
		return $night;
	});
	$app->helper(closed => sub {
		my $c = shift;
		return $c->config->{closed} if defined $c->config->{closed}; #&& $c->app->mode ne 'development';
		return 1 unless @{$c->hours};
		my $closed = $c->datetime >= $c->hours($c->auctions->[0])->[0] && $c->datetime <= $c->hours($c->auctions->[0])->[1] ? 0 : 1;
		#warn Data::Dumper::Dumper({closed=>$closed, hours=>[$c->hours->[0]->datetime, $c->hours->[1]->datetime]});
		return $closed;
	});
	$app->helper(in_progress => sub {
		my ($c, $year) = @_;
		return $c->config->{in_progress} if defined $c->config->{in_progress};
		return 0 unless @{$c->hours};
		my $range = $c->config->{auctions}->{$c->years($year)->[0]} or return wantarray ? () : [];
		my @auctions = $c->range($range);
		my $in_progress = $c->datetime >= $c->hours($c->auctions->[0])->[0] && $c->datetime <= $c->hours($c->auctions->[-1])->[1];
		#warn Data::Dumper::Dumper([$c->datetime->datetime, $c->hours($c->auctions->[0])->[0]->datetime, $c->hours($c->auctions->[-1])->[1]->datetime]);
		return $in_progress;
	});
}

1;

=head1 NAME

Mojolicious::Plugin::MyStash - Access request as MyStash

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('MyStash');

  # Mojolicious::Lite
  plugin 'MyStash';

=head1 DESCRIPTION

L<Mojolicious::Plugin::MyStash> accesses request as MyStash for L<Mojolicious>.

=head1 HELPERS

L<Mojolicious::Plugin::MyStash> implements the following helpers.

=head2 json

  %= json 'foo'

=head1 METHODS

L<Mojolicious::Plugin::MyStash> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register helpers in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
