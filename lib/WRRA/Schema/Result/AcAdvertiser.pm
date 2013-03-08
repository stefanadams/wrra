package WRRA::Schema::Result::AcAdvertiser;

use base 'WRRA::Schema::Result::Donor';

sub default {
	my ($self, $rs, $req) = @_;
	$rs->search({-or => [name=>{'like'=>'%'.$req->{term}.'%'}, donor_id=>$req->{term}]}, {group_by=>'donor_id', order_by=>'name'})
}

sub label { shift->nameid }
sub ad { shift->nameid }

sub TO_VIEW { qw/label ad url/ }

1;
