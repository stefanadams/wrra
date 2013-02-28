package WRRA::Schema::ResultView::ResultSet::AcCity;

sub default { shift->search({}, {group_by=>'city', order_by=>'city'}) }

1;
