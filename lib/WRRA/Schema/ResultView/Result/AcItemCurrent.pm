package WRRA::Schema::ResultView::Result::AcItemCurrent;

sub label { shift->name }
sub desc { shift->year }

sub TO_VIEW { qw/label desc description _value category url/ }

1;
