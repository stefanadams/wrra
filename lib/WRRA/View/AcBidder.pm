package WRRA::View::AcBidder;

sub search {
	my $class = shift;
	my $request = shift;
	my $resolver = shift;

	my ($term) = ($request->{term});

	return (-or => ['me.name'=>{'like' => $term.'%'}, 'me.bidder_id'=>$term]);
}

1;
