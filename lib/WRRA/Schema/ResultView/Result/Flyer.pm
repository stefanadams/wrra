package WRRA::Schema::ResultView::Result::Flyer;

use base 'WRRA::Schema::Result::Item';

sub _columns { qw/name value scheduled.day_name/ }

1;
