package WRRA::Schema::ResultModel::Postcards;

use base 'WRRA::Schema::Result::Donor';

sub TO_XLS { shift->arrayref(qw(name contact1 contact2 address city state zip)) }

1;
