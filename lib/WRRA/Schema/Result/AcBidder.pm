package WRRA::Schema::Result::AcBidder;

use base 'WRRA::Schema::Result::Bidder';

sub _columns { qw/label desc/ }
sub label { shift->nameid }
sub desc { shift->phone }

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({-or => ['name'=>{'like' => '%'.$req->{term}.'%'}, 'bidder_id'=>$req->{term}, 'phone'=>'%'.$req->{term}.'%']}, {group_by=>'bidder_id', order_by=>'name'})
}

1;
