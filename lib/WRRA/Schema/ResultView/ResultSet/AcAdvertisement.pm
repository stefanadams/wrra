package WRRA::Schema::ResultView::ResultSet::AcAdvertisement;

sub default { shift->search({}, {group_by=>'advertisement', order_by=>'advertisement'}) }

1;
