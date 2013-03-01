package WRRA::Schema::ResultView::Result::Stockitems;

use base 'WRRA::Schema::Result::Stockitem';

sub _columns { qw/id category name value cost/ }

1;
