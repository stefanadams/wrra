package WRRA::Schema::ResultView::ResultSet::AcStockitem;

sub default {
	my ($self, $req) = @_;
	$self->search({name=>{'like' => '%'.$req->{term}.'%'}}, {group_by=>'name', order_by=>'name'})->current_year
}

1;
