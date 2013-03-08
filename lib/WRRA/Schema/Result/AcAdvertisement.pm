package WRRA::Schema::Result::AcAdvertisement;

use base 'WRRA::Schema::Result::Donor';

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({-or => [donor_id=>$req->{term}, advertisement=>{'like' => '%'.$req->{term}.'%'}]}, {group_by=>'advertisement', order_by=>'advertisement'})
}

sub label { shift->advertisement }

sub TO_VIEW { qw/label/ }

1;
