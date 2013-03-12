package WRRA::Schema::Result::Postcards;

use base 'WRRA::Schema::Result::Donor';

sub _colmodel { qw/name contact1 contact2 address city state zip/ }

sub _search { $_[1]->solicit } 

1;
