package WRRA::Schema::Result::Bankreport;

use base 'WRRA::Schema::Result::Item';

sub _colmodel { qw/sold.day_name number name highbid.bid highbid.bidder.name value donor.name/ }

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({}, {order_by=>['scheduled','number']})->current_year->sold
}

1;
