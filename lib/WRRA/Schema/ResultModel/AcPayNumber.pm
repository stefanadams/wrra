package WRRA::Schema::ResultModel::AcPayNumber;

use base 'WRRA::Schema::Result::Item';

sub TO_JSON { shift->hashref(qw(city state zip)) }

1;
