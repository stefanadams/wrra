package WRRA::Schema::Result::Bidders;

use base 'WRRA::Schema::Result::Bidder';

sub _search {
        my ($self, $rs, $req) = @_;
        $rs->current_year;
}

sub TO_VIEW { qw/id name email phone address city state zip/ }

1;
