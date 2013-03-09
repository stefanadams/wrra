package WRRA::Bidding;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::JSON;

sub read {
	my $self = shift;
	my $rs = $self->db->resultset($self->param('results'))->current_year->not_ready;
	my $bidding = Mojo::JSON->new->decode(Mojo::JSON->new->encode([$rs->all]));
	foreach ( @$bidding ) {
		# if((find_in_set('newbid',`items`.`notify`) > 0),1,NULL) `newbid`
		# if((`items`.`status` = 'Sold'),1,NULL) `sold`
		$_->{img} = (glob($self->config('photos')."2012/$_->{number}.*"))[0] if $_->{number};
		$_ = $self->_fakebidding($_);
		$_->{notify} = {map { $_ => 1 } split /,/, $_->{notify}};
	}
warn Data::Dumper::Dumper($bidding);
	$self->respond_to(
		json => {json => {bidding=>{rows=>$bidding}}},
	);
}

sub _fakebidding {
	my $self = shift;
	my $row = shift;
	return $row unless $self->app->mode eq 'development';
	my @notify = ();
	if ( int(rand(99)) < 25 ) {
		$row->{status} = 'Ready'; 
	} elsif ( int(rand(99)) < 25 ) {
		$row->{status} = 'OnDeck';
		$row->{auctioneer} = int(rand(99)) < 50 ? 'a' : 'b';
	} elsif ( int(rand(99)) < 100 ) {
		$row->{status} = 'Bidding';
		push @notify, 'newbid' if int(rand(99)) < 20;
		if ( int(rand(99)) < 25 ) {
			push @notify, 'starttimer';
		} elsif ( int(rand(99)) < 25 ) {
			push @notify, 'sell';
		}
		$row->{auctioneer} = int(rand(99)) < 50 ? 'a' : 'b';
		$row->{highbid}->{bid} = $row->{highbid}->{bid} =~ /\d/ ? $row->{highbid}->{bid} : $row->{value} - 10 + int(rand(15));
		$row->{bellringer} = $row->{highbid}->{bid} >= $row->{value};
		$row->{highbid}->{bidder}->{name} = substr($row->{donor}->{name}, 0, 18);
		$row->{timer} = int(rand(99)) < 20 ? 1 : 0;
	} elsif ( int(rand(99)) < 25 ) {
		$row->{status} = 'Sold';
	} elsif ( int(rand(99)) < 25 ) {
		$row->{status} = 'Complete';
	}
	$row->{description} ||= int(rand(99)) < 20 ? 'Fuller description' : undef;
	$row->{url} ||= int(rand(99)) < 20 ? 'http://google.com' : undef;
	$row->{donor}->{url} ||= int(rand(99)) < 20 ? 'http://google.com' : undef;
	$row->{img} ||= int(rand(99)) < 20 ? 'http://dev.washingtonrotary.com/rra/img/right_arrow_button.gif' : undef;
	$row->{notify} = join ',', @notify;
	return $row;
}

1;
