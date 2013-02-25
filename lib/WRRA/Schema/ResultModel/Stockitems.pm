package WRRA::Schema::ResultModel::Stockitems;

use base 'WRRA::Schema::Result::Stockitem';

sub resolver {
	create_defaults => {
		year => sub { shift->year },
	},
}

sub TO_XLS { shift->arrayref(qw(id category name value cost)) }
sub TO_JSON { shift->hashref(qw(id category name value cost)) }

1;
