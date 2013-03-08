package WRRA::Schema::Result::Bids;

use base 'WRRA::Schema::Result::Bid';

sub _search {
        my ($self, $rs, $req) = @_;
        $rs->search_related('item')->current_year;
}

sub TO_VIEW { qw/id bid_r bid bidtime bidder.id bidder.nameid bidder.phone item.id item.nameid item.value item.bellringer/ }

1;
