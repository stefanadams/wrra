package WRRA::Schema::ResultView::Result::Stockitems;

use base 'WRRA::Schema::Result::Stockitem';

sub TO_VIEW { qw/id category name value cost/ }

1;
