package WRRA::Schema::Result::Stockitems;

use base 'WRRA::Schema::Result::Stockitem';

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->current_year;
} 

sub TO_VIEW { qw/id category name value cost/ }

1;
