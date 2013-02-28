package WRRA::Schema::ResultView::ResultSet::AcAd;

sub default { shift->search({}, {prefetch=>'advertiser', group_by=>'me.advertiser_id', order_by=>'me.name'}) }

1;
