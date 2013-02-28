package WRRA::Schema::ResultView::ResultSet::SeqItems;

sub default { shift->search({}, {order_by=>{'-asc'=>['scheduled','seq']}})->current_year }

1;
