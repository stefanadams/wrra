package WRRA::Schema::Result::Items;

use base 'WRRA::Schema::Result::Item';

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->current_year;
}

sub TO_VIEW { qw/id number donor.id donor.nameid donor.advertisement stockitem.id stockitem.nameid name description value category url/ }

1;
