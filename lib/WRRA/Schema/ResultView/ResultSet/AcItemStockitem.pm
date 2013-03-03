package WRRA::Schema::ResultView::ResultSet::AcItemStockitem;

sub default {
	my ($self, $req) = @_;
	$self->search({name=>{'like' => $req->{term}.'%'}}, {group_by=>'stockitem.name', order_by=>'stockitem.name'})->current_year
}

1;
