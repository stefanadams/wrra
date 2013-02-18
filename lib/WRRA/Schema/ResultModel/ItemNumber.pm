package WRRA::Schema::ResultModel::ItemNumber;

use base 'WRRA::Schema::Result::Item';

sub TO_JSON { shift->hashref(qw(number)) }

1;
