package WRRA::Schema::Result::BsRotarians;

use base 'WRRA::Schema::Result::Rotarian';

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({}, {order_by=>'lastname'});
} 

sub TO_VIEW { qw/id name/ }

1;
