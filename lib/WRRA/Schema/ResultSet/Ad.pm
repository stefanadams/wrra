package WRRA::Schema::ResultSet::Ad;
use base 'WRRA::Schema::ResultSet';

sub random { shift->search({}, {prefetch=>'adcount', order_by=>[{'-asc'=>'rotate'}, \'RAND()']}) }

1;
