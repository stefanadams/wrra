package WRRA::Schema::Result::AcItem;

use base 'WRRA::Schema::Result::Item';

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({-or => ['me.number'=>$req->{term},'me.name'=>{'like' => '%'.$req->{term}.'%'}, 'donor.name'=>{'like' => '%'.$req->{term}.'%'}]}, {group_by=>'name', order_by=>'name'})->recent_years
}

sub label { shift->name }

sub TO_VIEW { qw/label description _value url category/ }

1;
