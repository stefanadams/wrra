package WRRA::Schema::ResultView::ResultSet::AcDonor;

sub default { shift->search({}, {group_by=>'me.donor_id', order_by=>'me.name'}) }

1;
