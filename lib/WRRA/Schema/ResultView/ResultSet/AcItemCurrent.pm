package WRRA::Schema::ResultView::ResultSet::AcItemCurrent;

sub default { shift->search({}, {group_by=>'me.name', order_by=>'me.name'})->current_year }

1;
