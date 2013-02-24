package WRRA::View::DonorItems;

sub search {
	my $class = shift;
	my $request = shift;
	my $resolver = shift;

	return (donor_id => $request->{id});
}

1;
