package WRRA::Schema::Result::Stockreport;

use base 'WRRA::Schema::Result::Item';

sub _colmodel { qw/stockitem.name count stockitem.value stockitem.cost/ }
sub count { shift->get_column('count') }

# The relationships associated with this result (table)
our $relationships = [qw/stockitem/];

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({}, {prefetch=>'stockitem', 'select'=>['me.stockitem_id', 'number', 'scheduled', 'sold', 'started', 'me.year', 'stockitem.name', {count=>'me.stockitem_id','-as'=>'count'}, 'stockitem.value', 'stockitem.cost'], group_by=>'me.stockitem_id'})->current_year->sold
}

1;
