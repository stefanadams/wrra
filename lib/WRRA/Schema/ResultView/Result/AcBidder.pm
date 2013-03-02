package WRRA::Schema::ResultView::Result::AcBidder;

sub label { shift->nameid }
sub desc { shift->phone }

sub TO_VIEW { qw/label desc/ }

1;
