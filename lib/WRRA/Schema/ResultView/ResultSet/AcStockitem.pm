package WRRA::Schema::ResultView::ResultSet::AcStockitem;

sub default { shift->search({}, {group_by=>'name', order_by=>'name'})->current_year }

1;
