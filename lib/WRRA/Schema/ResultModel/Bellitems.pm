package WRRA::Schema::ResultModel::Bellitems;

use base 'WRRA::Schema::Result::Bellitem';

sub resolver {
	create_defaults => {
		year => sub { shift->year },
	},
}

sub TO_XLS { shift->arrayref(qw(id name)) }
sub TO_JSON { shift->hashref(qw(id name)) }

1;
