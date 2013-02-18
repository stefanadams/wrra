package WRRA::Schema::ResultModel::AcBellitem;

use base 'WRRA::Schema::Result::Bellitem';

sub TO_JSON { shift->hashref(qw(city state zip)) }

1;
