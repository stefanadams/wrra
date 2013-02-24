package WRRA::Schema::ResultModel::Bids;

use base 'WRRA::Schema::Result::Bid';

sub resolver {
	search => {
		#name => \'concat(lastname, ", ", firstname)',
		#highbidder => 'bidder.name',
		#highbid => 'highbid.bid',
		#soldday => \'dayname(sold)',
	},
	order_by => {
		#name => ['lastname', 'firstname'],
		#soldday => [\'cast(sold as date)', 'number'],
	},
	update_or_create => {
		#'id' => sub { rotarian_id=>shift },
		#'name' => sub {
		#	my ($last, $first) = (shift =~ /^([^,]+), ([^,]+)$/);
		#	return lastname=>$last,firstname=>$first;
		#},
	},
	validate => {
		#name => qr/^([^,]+), ([^,]+)$/,
	},
}

sub TO_XLS { shift->arrayref(qw(id bidder item bid_r bid bidtime)) }
sub TO_JSON {
	my $self = shift;
	return {
		(map { $_ => $self->$_ } qw(id bid_r bid bidtime)),
		bidder => {
			nameid => $self->eval('$self->bidder->nameid'),
			phone => $self->eval('$self->bidder->phone'),
		},
		item => {
			nameid => $self->eval('$self->item->nameid'),
			value => $self->eval('$self->item->value'),
			bellringer => $self->eval('$self->item->bellringer'),
		},
	};
}

1;
