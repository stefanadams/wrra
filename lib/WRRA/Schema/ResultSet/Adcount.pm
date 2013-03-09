package WRRA::Schema::ResultSet::Adcount;
use base 'WRRA::Schema::ResultSet';

sub random { shift->search({}, {order_by=>[{'-asc'=>'rotate'}, \'RAND()']}) }

1;
