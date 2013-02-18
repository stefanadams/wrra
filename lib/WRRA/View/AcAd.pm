package WRRA::View::AcAd;

sub search {
	my $class = shift;
	my $request = shift;
	my $resolver = shift;

	my ($term) = ($request->{term});

	return (-or => [number=>$term, name=>{'like'=>'%'.$term.'%'}, 'donor.name'=>{'like'=>'%'.$term.'%'}, ad_id=>$term, 'donor.donor_id'=>$term]);
}

1;
