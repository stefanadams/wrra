package WRRA::Schema::ResultView::Result::BsRotarians;

use base 'WRRA::Schema::Result::Rotarian';

sub TO_VIEW { qw/id name/ }

1;
