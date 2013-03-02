package WRRA::Schema::ResultView::Result::Alerts;

use base 'WRRA::Schema::Result::Alert';

sub TO_VIEW { qw/id/ }

1;
