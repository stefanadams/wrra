package WRRA::Schema::ResultView::Result::AcCity;

sub label { shift->city }

sub TO_VIEW { qw/label state zip/ }

1;
