package WRRA::Schema::ResultView::Result::Bankreport;

use base 'WRRA::Schema::Result::Item';

sub _columns { qw/soldday name highbid.bid/ }

1;
