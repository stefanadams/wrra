package WRRA::Schema::ResultModel::Bellitems;

use base 'WRRA::Schema::Result::Bellitem';

sub resolver {
	update_or_create => {
		'id' => sub { bellitem_id=>shift },
	},
}

sub TO_XLS { shift->arrayref(qw(id name)) }
sub TO_JSON { shift->hashref(qw(id name)) }

1;
