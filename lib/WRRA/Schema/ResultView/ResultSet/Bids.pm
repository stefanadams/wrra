package WRRA::Schema::ResultView::ResultSet::Bids;

sub default { shift->search({})->search_related('item')->current_year }

1;
