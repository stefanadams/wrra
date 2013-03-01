package WRRA::Schema::ResultView::Result::AcAd;

use base 'WRRA::Schema::Result::Ad';

sub _columns { qw/id name advertiser.name/ }

1;
