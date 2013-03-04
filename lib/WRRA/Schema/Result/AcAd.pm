package WRRA::Schema::Result::AcAd;

use base 'WRRA::Schema::Result::Donor';

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({'me.name'=>{'like'=>'%'.$req->{term}.'%'}, 'advertiser.name'=>{'like'=>'%'.$req->{term}.'%'}, ad_id=>$req->{term}, 'advertiser.donor_id'=>$req->{term}}, {group_by=>'me.advertiser_id', order_by=>'me.name'})->current_year
}

sub label { shift->nameid }

sub TO_VIEW { qw/label url/ }

1;
