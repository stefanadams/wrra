package WRRA::Schema::ResultView::Result::Bankreport;

use base 'WRRA::Schema::Result::Item';

sub TO_VIEW { qw/soldday name highbid.bid/ }

1;
