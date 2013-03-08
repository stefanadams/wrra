package WRRA::Schema::Result::AcDonor;

use base 'WRRA::Schema::Result::Donor';

sub FROM_JSON { qw/label advertisement/ }

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({-or => ['name'=>{'like' => '%'.$req->{term}.'%'}, 'donor_id'=>$req->{term}]}, {group_by=>'donor_id', order_by=>'name'})
}

sub label { shift->nameid }

1;
