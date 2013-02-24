package WRRA::Schema::ResultModel::Alerts;

use base 'WRRA::Schema::Result::Alert';

sub TO_XLS { shift->arrayref(qw(alert msg)) }
sub TO_JSON { shift->hashref(qw(alert msg)) }

1;
