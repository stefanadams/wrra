package WRRA::Schema::ResultModel::AcItem;

use base 'WRRA::Schema::Result::Item';

sub label { shift->name }

sub TO_JSON { shift->hashref(qw(label description _value url category)) }

1;
