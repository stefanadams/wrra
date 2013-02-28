package WRRA::Schema::ResultView::ResultSet::AcItem;

sub default { shift->search({}, {prefetch=>'donor', group_by=>'me.name', order_by=>'me.name'})->recent_years }

1;
