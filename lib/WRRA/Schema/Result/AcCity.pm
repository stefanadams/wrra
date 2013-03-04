package WRRA::Schema::Result::AcCity;

use base 'WRRA::Schema::Result::Donor';

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({city=>{'-like' => '%'.$req->{term}.'%'}}, {group_by=>'city', order_by=>'city'})
}

sub label { shift->city }

sub TO_VIEW { qw/label state zip/ }

1;
