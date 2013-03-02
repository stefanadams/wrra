package WRRA::Schema::ResultView::Result::AcAdvertiser;

sub label { shift->nameid }
sub ad { shift->nameid }

sub TO_VIEW { qw/label ad url/ }

1;
