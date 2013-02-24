package WRRA::Schema::ResultModel::Stockitems;

use base 'WRRA::Schema::Result::Stockitem';

sub resolver {
	update_or_create => {
		'id' => sub { stockitem_id=>shift },
	},
}

sub TO_XLS { shift->arrayref(qw(id category name value cost)) }
sub TO_JSON { shift->hashref(qw(id category name value cost)) }

1;
