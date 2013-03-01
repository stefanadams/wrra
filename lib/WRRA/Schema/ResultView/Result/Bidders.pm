package WRRA::Schema::ResultView::Result::Bidders;

use base 'WRRA::Schema::Result::Bidder';

sub _columns { qw/id name email phone address city state zip/ }

1;
