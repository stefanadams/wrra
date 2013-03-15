package WRRA::Schema::Result::AcPayNumber;

use base 'WRRA::Schema::Result::Item';

sub _colmodel { qw/label desc id name highbid.bidder.id highbid.bidder.address highbid.bidder.city highbid.bidder.state highbid.bidder.zip/ }
sub label { shift->number }
sub desc { shift->name }

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({-or => ['number'=>$req->{term},'name'=>{'like' => '%'.$req->{term}.'%'}]}, {prefetch=>'highbid',group_by=>'number', order_by=>'number'})->current_year->sold->unpaid
}

1;
