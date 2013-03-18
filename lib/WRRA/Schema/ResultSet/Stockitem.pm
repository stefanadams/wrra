package WRRA::Schema::ResultSet::Stockitem;

use base 'WRRA::Schema::ResultSet';

my ($nu, $nn) = ({'='=>undef},{'!='=>undef});

sub sold { shift->search({scheduled=>$nn,started=>$nn,sold=>$nn}, {order_by=>'number'}) }

1;
