package WRRA::Schema::ResultModel::Stockitems;

use base 'WRRA::Schema::Result::Stockitem';

sub TO_XLS { shift->arrayref(qw(stockitem_id category name value cost)) }
sub TO_JSON { shift->hashref(qw(stockitem_id category name value cost)) }

1;
