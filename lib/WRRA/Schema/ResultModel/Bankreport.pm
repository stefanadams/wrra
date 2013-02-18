package WRRA::Schema::ResultModel::Bankreport;

use base 'WRRA::Schema::Result::Item';

sub resolver {
	search => {
		highbidder => 'bidder.name',
		highbid => 'highbid.bid',
		soldday => \'dayname(sold)',
	},
	order_by => {
		soldday => [\'cast(sold as date)', 'number'],
	},
};

sub highbid { shift->SUPER::highbid->bid }
sub highbidder { shift->SUPER::highbid->bidder->name }

sub TO_XLS { shift->arrayref(qw(soldday name highbid)) }
sub TO_JSON { shift->hashref(qw(soldday name highbid)) }

1;
