package WRRA::Schema::ResultView::ResultSet::Flyer;

sub default { shift->search({}, {order_by=>{'-asc'=>['scheduled','number']}})->current_year }

1;
