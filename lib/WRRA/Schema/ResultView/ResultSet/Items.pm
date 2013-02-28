package WRRA::Schema::ResultView::ResultSet::Items;

sub default { shift->search({}, {prefetch=>[qw/donor stockitem/]})->current_year }

1;
