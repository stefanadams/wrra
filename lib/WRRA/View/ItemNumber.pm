package WRRA::View::ItemNumber;

sub search {
	my $class = shift;
	my $request = shift;
	my $resolver = shift;

	my ($term) = ($request->{term});

	return ('me.item_id'=>$term);
}

1;
