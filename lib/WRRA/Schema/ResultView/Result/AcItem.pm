package WRRA::Schema::ResultView::Result::AcItem;

sub label { shift->name }

sub TO_VIEW { qw/label description _value url category/ }

1;
