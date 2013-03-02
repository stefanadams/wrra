package WRRA::Schema::ResultView::Result::AcStockitem;

sub label { shift->nameid }

sub TO_VIEW { qw/label name _value category/ }

1;
