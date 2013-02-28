package WRRA::Schema::ResultView::ResultSet::Donors;

sub default { shift->search({}, {prefetch=>'rotarian'}) }

1;
