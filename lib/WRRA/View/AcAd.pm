package WRRA::View::AcAd;

sub search {
	my $class = shift;
	my $request = shift;
	my $resolver = shift;

	my ($term) = ($request->{term});

	return ('me.name'=>{'like'=>'%'.$term.'%'}, 'advertiser.name'=>{'like'=>'%'.$term.'%'}, ad_id=>$term, 'advertiser.donor_id'=>$term);
}

1;
