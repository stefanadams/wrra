package WRRA::Schema::Result::AcStockitem;

use base 'WRRA::Schema::Result::Stockitem';

sub _colmodel { qw/label name _value category/ }

sub label { shift->nameid }

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({name=>{'like' => '%'.$req->{term}.'%'}}, {group_by=>'name', order_by=>'name'})->current_year
}

1;
