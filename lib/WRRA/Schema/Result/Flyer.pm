package WRRA::Schema::Result::Flyer;

use base 'WRRA::Schema::Result::Item';

sub _colmodel { qw/scheduled.day_name name donor.name value/ }

sub _search {
        my ($self, $rs, $req) = @_;
        $rs->search({}, {order_by=>{'-asc'=>['scheduled','number']}})->current_year
} 

1;
