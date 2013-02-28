package WRRA::Schema::ResultView::Result::Postcards;

use base 'WRRA::Schema::Result::Item';

sub _columns { qw/name contact1 contact2 address city state zip/ }

1;
