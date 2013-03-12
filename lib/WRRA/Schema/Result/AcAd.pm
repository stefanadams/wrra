package WRRA::Schema::Result::AcAd;

use base 'WRRA::Schema::Result::Ad';

sub _colmodel { qw/label url/ }

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({'-or'=>['me.name'=>{'like'=>'%'.$req->{term}.'%'}, 'advertiser.name'=>{'like'=>'%'.$req->{term}.'%'}, ad_id=>$req->{term}, 'advertiser.donor_id'=>$req->{term}]}, {join=>'advertiser', group_by=>'me.advertiser_id', order_by=>'me.name'})->current_year
}

sub label { shift->nameid }

1;
