package WRRA::Schema::Result::Alerts;

use base 'WRRA::Schema::Result::Alert';

sub _search {
	my ($self, $rs, $req) = @_;
	$rs;
}

sub TO_VIEW { qw/id/ }

1;
