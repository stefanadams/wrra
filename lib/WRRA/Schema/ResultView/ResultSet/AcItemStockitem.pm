package WRRA::Schema::ResultView::ResultSet::AcItemStockitem;

sub default { shift->search({}, {group_by=>'stockitem.name', order_by=>'stockitem.name'})->current_year }

1;
