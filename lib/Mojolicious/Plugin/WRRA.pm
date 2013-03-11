package Mojolicious::Plugin::WRRA;
use Mojo::Base 'Mojolicious::Plugin';

use List::MoreUtils qw(firstidx);
#use DateTime;
#use DateTime::Format::DateParse;
use DateTime::Format::MySQL;

sub register {
	my ($self, $app, $conf) = @_;
	my $moniker = uc($app->moniker);

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
		my $date_next = $c->hours($c->auctions->[0])->[0] || $c->hours($c->auctions($c->years->[1])->[0])->[0];
		#warn Data::Dumper::Dumper({date_next=>defined $date_next ? $date_next->ymd : ''});
		return $date_next;
	});
	$app->helper(night => sub {
		my ($c, $date) = @_;
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
		return 1 if $c->app->mode ne 'development' && $c->config->{closed};
		return 1 unless @{$c->hours};
		my $closed = $c->datetime >= $c->hours($c->auctions->[0])->[0] && $c->datetime <= $c->hours($c->auctions->[0])->[1] ? 0 : 1;
		#warn Data::Dumper::Dumper({closed=>$closed, hours=>[$c->hours->[0]->datetime, $c->hours->[1]->datetime]});
		return $closed;
	});
	$app->helper(header_data => sub {
		my $c = shift;
warn $c->is_user_authenticated;
#warn $c->current_user->{name};
		return {
			about => {
				$c->is_user_authenticated
					? (user => {
						name => $c->current_user->{name} || Mojo::JSON->false,
						role => $c->role || Mojo::JSON->false,
					  })
					: (),
				name => 'Washington Rotary Radio Auction',
				year => $c->datetime->year,
				night => defined $c->night ? $c->night : Mojo::JSON->false,
				closed => $c->closed,
				live => $c->closed ? 0 : 1,
				date_next => $c->date_next ? $c->date_next->format_cldr(q/EEE',' MMM d',' yyyy 'at' h':'mm':'ss/) : Mojo::JSON->false,
				datetime => $c->datetime,
			},
			play => $c->config('play'),
			alert => {
				msg => eval { $c->db->resultset('Alert')->search({alert=>'public'})->first->msg } || '',
			},
			ads => {
				ad => _display_ad($c),
			},
		};
	});
}

sub _display_ad {
        my $self = shift;
        my $adsdir = join '/', $self->app->home, 'public', ($self->config('ads') || 'ads');
        my $adsurl = join '/', ($self->config('ads') || 'ads');
        return $self->session->{ad} if $self->session->{ad_ctime} && time-$self->session->{ad_ctime} <= ($self->config->{refresh}->{ad} || 30000) / 1000;
        $self->session->{ad_ctime} = time;

        my $ad;
        foreach my $_ad ( $self->db->resultset('Ads')->today->random->all ) {
                $ad = {map { $_ => $_ad->$_ } qw/url year advertiser_id ad_id/};
		next if $ad->{ad_id} == $self->session->{ad}->{ad_id};
                my $r;
                if ( $r = $self->db->resultset('Adcount')->find($ad->{ad_id}, $self->datetime->ymd) ) {
                        $r->update({rotate=>($r->rotate||0)+1});
                } elsif ( $r = $self->db->resultset('Adcount')->new({ad_id=>$ad->{ad_id}, processed=>$self->datetime->ymd, rotate=>1}) ) {
                        $r->insert;
                }
		next unless $r;
                $ad->{img} = (glob("$adsdir/$ad->{year}/$ad->{advertiser_id}-$ad->{ad_id}.*"))[0] || (glob("$adsdir/$ad->{year}/$ad->{advertiser_id}.*"))[0] if $ad->{advertiser_id} && $ad->{ad_id};
                $ad->{img} && -e $ad->{img} && -f _ && -r _ && do {
                        $ad->{img} =~ s/^$adsdir\/?// or $ad->{img} = undef;
                        $ad->{img} = join '/', '', $adsurl, $ad->{img} if $ad->{img};
                        $r->update({display=>($r->display||0)+1}) and last;
			delete $ad->{ad_id};
                }
        }
        unless ( $ad->{ad_id} && $ad->{img} && $ad->{url} ) {
                $ad->{ad_id} = $self->config->{default_ad}->{ad_id};
                $ad->{advertiser_id} = $self->config->{default_ad}->{advertiser_id};
                $ad->{img} = $adsdir.'/'.$self->config->{default_ad}->{img};
                $ad->{url} = $self->config->{default_ad}->{url};
        }
        $self->session->{ad} = $ad;
        $ad->{refresh} = 1;
	return $ad;
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