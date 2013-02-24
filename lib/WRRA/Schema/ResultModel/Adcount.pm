package WRRA::Schema::ResultModel::Adcount;

use base 'WRRA::Schema::Result::Adcount';

sub resolver {
	update_or_create => {
		'id' => sub { adcount_id=>shift },
	},
}

sub TO_XLS { shift->arrayref(qw(id processed rotate display click)) }
sub TO_JSON { shift->hashref(qw(id processed rotate display click)) }

1;
