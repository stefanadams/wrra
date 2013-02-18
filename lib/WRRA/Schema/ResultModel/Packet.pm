package WRRA::Schema::ResultModel::Packet;

use base 'WRRA::Schema::Result::Donor';

sub TO_XLS { shift->arrayref(qw(name contact1 contact2 address city state zip)) }
sub TO_JSON { shift->hashref(qw(name contact1 contact2 address city state zip)) }

1;
