package WRRA::Schema::Result::Bankreport;

use base 'WRRA::Schema::Result::Item';

sub _search {
        my ($self, $rs, $req) = @_;
        $rs;
}

sub TO_VIEW { qw/soldday name highbid.bid/ }

1;
