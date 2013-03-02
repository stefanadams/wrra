package WRRA::Schema::ResultView::Result::AcAd;

sub label { shift->nameid }

sub TO_VIEW { qw/label url/ }

1;
