package WRRA::Schema::ResultModel::Rotarians;

use base 'WRRA::Schema::Result::Rotarian';

sub resolver {
	search => {
		name => \'concat(lastname, ", ", firstname)',
		#highbidder => 'bidder.name',
		#highbid => 'highbid.bid',
		#soldday => \'dayname(sold)',
	},
	order_by => {
		name => ['lastname', 'firstname'],
		#soldday => [\'cast(sold as date)', 'number'],
	},
	update_or_create => {
		'id' => sub { rotarian_id=>shift },
		'name' => sub {
			my ($last, $first) = (shift =~ /^([^,]+), ([^,]+)$/);
			return lastname=>$last,firstname=>$first;
		},
	},
	validate => {
		name => qr/^([^,]+), ([^,]+)$/,
	},
}

sub TO_XLS { shift->arrayref(qw(id has_submissions name email phone)) }
sub TO_JSON { shift->hashref(qw(id has_submissions name email phone)) }

1;
