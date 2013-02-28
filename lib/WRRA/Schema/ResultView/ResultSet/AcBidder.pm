package WRRA::Schema::ResultView::ResultSet::AcBidder;

sub default { shift->search({}, {group_by=>'me.bidder_id', order_by=>'me.name'}) }

1;
