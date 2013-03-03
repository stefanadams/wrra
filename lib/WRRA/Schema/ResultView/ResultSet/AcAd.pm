package WRRA::Schema::ResultView::ResultSet::AcAd;

sub default {
	my ($self, $req) = @_;
	$self->search({'me.name'=>{'like'=>'%'.$req->{term}.'%'}, 'advertiser.name'=>{'like'=>'%'.$req->{term}.'%'}, ad_id=>$req->{term}, 'advertiser.donor_id'=>$req->{term}}, {group_by=>'me.advertiser_id', order_by=>'me.name'})->current_year
}

1;
