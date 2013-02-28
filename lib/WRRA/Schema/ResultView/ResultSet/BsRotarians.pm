package WRRA::Schema::ResultView::ResultSet::BsRotarians;

sub default { shift->search({}, {order_by=>'lastname'}) }

1;
