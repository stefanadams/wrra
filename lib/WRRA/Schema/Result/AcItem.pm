package WRRA::Schema::Result::AcItem;

use base 'WRRA::Schema::Result::Item';

sub FROM_JSON { qw/label description _value url category/ }

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({-or => ['me.number'=>$req->{term},'me.name'=>{'like' => '%'.$req->{term}.'%'}, 'donor.name'=>{'like' => '%'.$req->{term}.'%'}]}, {join=>'donor', group_by=>'donor.name', order_by=>'donor.name'})->recent_years
}

sub label { shift->name }

1;
