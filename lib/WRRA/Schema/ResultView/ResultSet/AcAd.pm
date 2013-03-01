package WRRA::Schema::ResultView::ResultSet::AcAd;

sub default { shift->search({}, {group_by=>'me.advertiser_id', order_by=>'me.name'})->current_year }

1;
