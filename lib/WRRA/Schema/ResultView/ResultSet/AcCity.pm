package WRRA::Schema::ResultView::ResultSet::AcCity;

sub default {
	my ($self, $req) = @_;
	$self->search({city=>{'-like' => '%'.$req->{term}.'%'}}, {group_by=>'city', order_by=>'city'})
}

1;
