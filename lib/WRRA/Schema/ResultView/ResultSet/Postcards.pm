package WRRA::Schema::ResultView::ResultSet::Postcards;

sub default { shift->search({}, {order_by=>{'-asc'=>'name'}})->solicit }

1;
