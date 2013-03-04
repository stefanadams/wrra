package WRRA::Schema::Result::DonorItems;

use base 'WRRA::Schema::Result::Item';

sub _search {
	my ($self, $rs, $req) = @_;
	#$rs->search({}, {order_by=>['year desc', 'sold asc']});
	$rs
} 

sub TO_VIEW { qw/year value bellringer sold.day_name highbid.bid/ }

1;
