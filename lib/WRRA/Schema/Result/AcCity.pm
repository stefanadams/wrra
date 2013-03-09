package WRRA::Schema::Result::AcCity;

use base 'WRRA::Schema::Result::Donor';

sub _colmodel { qw/label state zip/ }

sub label { shift->city }

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({city=>{'-like' => '%'.$req->{term}.'%'}}, {group_by=>'city', order_by=>'city'});
};

1;
