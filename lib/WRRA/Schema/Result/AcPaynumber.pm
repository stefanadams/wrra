package WRRA::Schema::Result::AcPaynumber;

use base 'WRRA::Schema::Result::Item';

sub _search {
	my ($self, $rs, $req) = @_;
	$rs;
}

sub TO_VIEW { qw/id/ }

1;
