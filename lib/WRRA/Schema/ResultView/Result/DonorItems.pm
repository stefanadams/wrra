package WRRA::Schema::ResultView::Result::DonorItems;

use base 'WRRA::Schema::Result::Item';

sub _columns { qw/year value bellringer sold.day_name highbid.bid/ }

1;
