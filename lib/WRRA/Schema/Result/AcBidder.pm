package WRRA::Schema::Result::AcBidder;

use base 'WRRA::Schema::Result::Bidder';

sub _colmodel { qw/label phone id/ }
sub label { shift->name }

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({-or => ['name'=>{'-like' => '%'.$req->{term}.'%'}, 'bidder_id'=>$req->{term}, 'phone' => {'-like' => '%'.$req->{term}.'%'}]}, {group_by=>'bidder_id', order_by=>'name'})->current_year
}

1;
