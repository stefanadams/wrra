package WRRA::Schema::Result::SeqItems;

use base 'WRRA::Schema::Result::Item';

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({}, {order_by=>{'-asc'=>['scheduled','seq']}})->current_year
} 

sub TO_VIEW { qw/id number name value scheduled.day_name/ }

1;
