package WRRA::Schema::ResultView::Result::Bidders;

use base 'WRRA::Schema::Result::Bidder';

sub TO_VIEW { qw/id name email phone address city state zip/ }

1;
