package WRRA::Schema::ResultView::Result::Bellitems;

use base 'WRRA::Schema::Result::Bellitem';

sub TO_VIEW { qw/id name/ }

1;
