package WRRA::Schema::Result::AcAdvertiser;

use base 'WRRA::Schema::Result::Ad';

sub _colmodel { qw/label value url/ }
sub label { shift->advertiser->name }
sub value { shift->name }

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({'-or'=>['me.name'=>{'like'=>'%'.$req->{term}.'%'}, 'advertiser.name'=>{'like'=>'%'.$req->{term}.'%'}, ad_id=>$req->{term}, 'advertiser.donor_id'=>$req->{term}]}, {join=>'advertiser', group_by=>'me.advertiser_id', order_by=>'me.name'})
}

1;
