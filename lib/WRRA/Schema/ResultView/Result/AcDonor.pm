package WRRA::Schema::ResultView::Result::AcDonor;

sub label { shift->nameid }

sub TO_VIEW { qw/label advertisement/ }

1;
