package WRRA::View::AcItemStockitem;

sub search {
	my $class = shift;
	my $request = shift;
	my $resolver = shift;

	my ($term) = ($request->{term});

	return (name=>{'like' => $term.'%'});
}

1;
