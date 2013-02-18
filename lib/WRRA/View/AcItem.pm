package WRRA::View::AcItem;

sub search {
	my $class = shift;
	my $request = shift;
	my $resolver = shift;

	my ($term) = ($request->{term});

	return (-or => ['me.number'=>$term,'me.name'=>{'like' => '%'.$term.'%'}, 'donor.name'=>{'like' => '%'.$term.'%'}]);
}

1;
