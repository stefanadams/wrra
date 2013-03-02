package WRRA::Schema::ResultView::Result::Flyer;

use base 'WRRA::Schema::Result::Item';

sub TO_VIEW { qw/name value scheduled.day_name/ }

1;
