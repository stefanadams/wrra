package WRRA::Schema::Result::AcBidder;

use base 'WRRA::Schema::Result::Bidder';

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({-or => ['me.name'=>{'like' => $req->{term}.'%'}, 'me.bidder_id'=>$req->{term}]}, {group_by=>'me.bidder_id', order_by=>'me.name'})
}

sub label { shift->nameid }
sub desc { shift->phone }

sub TO_VIEW { qw/label desc/ }

1;
