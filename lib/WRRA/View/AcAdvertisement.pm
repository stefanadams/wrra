package WRRA::View::AcAdvertisement;

sub search {
	my $class = shift;
	my $request = shift;
	my $resolver = shift;

	my ($term) = ($request->{term});

	return (-or => [donor_id=>$term, advertisement=>{'like' => '%'.$term.'%'}]);
}

1;
