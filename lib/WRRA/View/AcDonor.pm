package WRRA::View::AcDonor;

sub search {
	my $class = shift;
	my $request = shift;
	my $resolver = shift;

	my ($term) = ($request->{term});

	return (-or => ['me.name'=>{'like' => $term.'%'}, 'me.donor_id'=>$term]);
}

1;
