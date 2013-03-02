package WRRA::Schema::ResultView::Result::AcAdvertisement;

sub label { shift->advertisement }

sub TO_VIEW { qw/label/ }

1;
