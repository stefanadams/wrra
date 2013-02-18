package WRRA::View::AcAdvertiser;

sub search {
	my $class = shift;
	my $request = shift;
	my $resolver = shift;

	my ($term) = ($request->{term});

	return (-or => [name=>{'like'=>'%'.$term.'%'}, donor_id=>$term]);
}

1;
