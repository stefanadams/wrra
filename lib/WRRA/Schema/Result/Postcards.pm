package WRRA::Schema::Result::Postcards;

use base 'WRRA::Schema::Result::Donor';

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({}, {order_by=>{'-asc'=>'name'}})->solicit
} 

sub TO_VIEW { qw/name contact1 contact2 address city state zip/ }

1;
