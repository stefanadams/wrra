package WRRA::Schema::Result::Ads;

use base 'WRRA::Schema::Result::Donor';

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->current_year
}

sub TO_VIEW { qw/id/ }

1;
