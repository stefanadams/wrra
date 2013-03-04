package WRRA::Schema::Result::AcItemCurrent;

use base 'WRRA::Schema::Result::Item';

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({-or => ['me.number'=>$req->{term},'me.name'=>{'like' => '%'.$req->{term}.'%'}]}, {group_by=>'me.name', order_by=>'me.name'})->current_year
}

sub label { shift->name }
sub desc { shift->year }

sub TO_VIEW { qw/label desc description _value category url/ }

1;
