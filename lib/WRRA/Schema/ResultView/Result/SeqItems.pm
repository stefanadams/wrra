package WRRA::Schema::ResultView::Result::SeqItems;

use base 'WRRA::Schema::Result::Item';

sub TO_VIEW { qw/id number name value scheduled.day_name/ }

1;
