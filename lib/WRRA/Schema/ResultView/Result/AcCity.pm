package WRRA::Schema::ResultView::Result::AcCity;

use base 'WRRA::Schema::Result::Donor';

sub label { shift->city }

sub TO_VIEW { qw/label state zip/ }

1;
