package WRRA::Schema::Result::BsRotarians;

use base 'WRRA::Schema::Result::Rotarian';

sub FROM_JSON { qw/id name/ }

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({}, {order_by=>'lastname'});
} 

1;
