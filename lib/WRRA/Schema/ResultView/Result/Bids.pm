package WRRA::Schema::ResultView::Result::Bids;

use base 'WRRA::Schema::Result::Bid';

sub TO_VIEW { qw/id bid_r bid bidtime bidder.id bidder.nameid bidder.phone item.id item.nameid item.value item.bellringer/ }

1;
