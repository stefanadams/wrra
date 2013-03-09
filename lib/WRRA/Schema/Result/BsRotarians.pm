package WRRA::Schema::Result::BsRotarians;

use base 'WRRA::Schema::Result::Rotarian';

sub _colmodel { qw/id name/ }

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({}, {order_by=>'lastname'});
} 

1;
