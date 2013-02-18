package WRRA::Schema::ResultModel::Ads;

use base 'WRRA::Schema::Result::Ad';

sub TO_XLS { shift->arrayref(qw(name)) }
sub TO_JSON { shift->hashref(qw(name)) }

1;
