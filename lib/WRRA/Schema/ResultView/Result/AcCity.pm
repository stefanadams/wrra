package WRRA::Schema::ResultView::Result::AcCity;

use base 'WRRA::Schema::Result::Donor';

sub label { shift->city }

sub _columns { qw/label state zip/ }

1;
