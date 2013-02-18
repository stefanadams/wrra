package WRRA::Schema::ResultModel::Bidders;

use base 'WRRA::Schema::Result::Bidder';

sub TO_XLS { shift->arrayref(qw(name)) }
sub TO_JSON { shift->hashref(qw(name)) }

1;
