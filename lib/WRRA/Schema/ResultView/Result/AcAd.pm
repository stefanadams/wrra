package WRRA::Schema::ResultView::Result::AcAd;

use base 'WRRA::Schema::Result::Ad';

sub TO_VIEW { qw/id name advertiser.name/ }

1;
