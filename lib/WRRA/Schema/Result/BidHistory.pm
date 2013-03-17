package WRRA::Schema::Result::BidHistory;

use base 'WRRA::Schema::Result::Bid';

sub _colmodel { qw/bidder.name bid/ }

1;
