package WRRA::Schema::ResultModel::DonorItems;

use base 'WRRA::Schema::Result::Item';

sub TO_XLS { shift->arrayref(qw(value)) }
sub TO_JSON { shift->hashref(qw(value)) }

1;
