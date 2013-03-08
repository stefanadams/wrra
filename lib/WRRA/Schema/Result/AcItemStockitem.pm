package WRRA::Schema::Result::AcItemStockitem;

use base 'WRRA::Schema::Result::Stockitem';

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({name=>{'like' => $req->{term}.'%'}}, {group_by=>'stockitem.name', order_by=>'stockitem.name'})->current_year
}

sub TO_VIEW { qw/stockitem value/ }

1;
