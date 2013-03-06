package WRRA::Schema::Result::Bellitems;

use base 'WRRA::Schema::Result::Bellitem';

sub _search {
        my ($self, $rs, $req) = @_;
        $rs->current_year;
}

sub TO_VIEW { qw/id name/ }

1;
