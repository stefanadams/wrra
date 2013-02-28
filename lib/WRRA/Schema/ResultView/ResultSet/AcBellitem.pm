package WRRA::Schema::ResultView::ResultSet::AcBellitem;

sub default { shift->search({}, {group_by=>'name', order_by=>'name'}) }

1;
