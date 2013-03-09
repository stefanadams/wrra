package WRRA::Schema::Result::SeqItems;

use base 'WRRA::Schema::Result::Item';

sub _colmodel { qw/id number name value scheduled.day_name/ }

1;
