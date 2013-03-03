package WRRA::Schema::ResultView::ResultSet::AcCity;

sub default {
	my $self = shift;
	$self->search({city=>{'-like' => '%'.$self->get_myrequest->{term}.'%'}}, {group_by=>'city', order_by=>'city'})
}

1;
