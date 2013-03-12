package WRRA::Schema::Result::AcAdvertiser;

use base 'WRRA::Schema::Result::Donor';

sub _colmodel { qw/label ad url/ }

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({-or => [name=>{'like'=>'%'.$req->{term}.'%'}, donor_id=>$req->{term}]}, {group_by=>'donor_id', order_by=>'name'})
}

sub label { shift->nameid }
sub ad { shift->nameid }

1;
