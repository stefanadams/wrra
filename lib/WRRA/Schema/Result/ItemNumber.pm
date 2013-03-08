package WRRA::Schema::Result::ItemNumber;

use base 'WRRA::Schema::Result::Item';

sub _search {
	my ($self, $rs, $req) = @_;
	$rs;
} 

sub TO_VIEW { qw/number/ }

1;
