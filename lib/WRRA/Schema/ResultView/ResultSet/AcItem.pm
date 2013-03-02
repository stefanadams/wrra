package WRRA::Schema::ResultView::ResultSet::AcItem;

sub default { shift->search({}, {group_by=>'me.name', order_by=>'me.name'})->recent_years }

1;
