package WRRA::View::AcCity;

sub search {
	my $class = shift;
	my $request = shift;
	my $resolver = shift;

	my ($term) = ($request->{term});

	return (-or => [city=>{'like' => $term.'%'}, state=>{'like' => $term.'%'}, zip=>{'like' => $term.'%'}]);
}

1;
