package WRRA::Schema::ResultView::ResultSet::AcAdvertiser;

sub default { shift->search({}, {group_by=>'donor_id', order_by=>'name'}) }

1;
