package WRRA::Schema::Result::Flyer;

use base 'WRRA::Schema::Result::Item';

sub _search {
        my ($self, $rs, $req) = @_;
        $rs->search({}, {order_by=>{'-asc'=>['scheduled','number']}})->current_year
} 

sub TO_VIEW { qw/name value scheduled.day_name/ }

1;
