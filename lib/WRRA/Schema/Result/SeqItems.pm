package WRRA::Schema::Result::SeqItems;

use base 'WRRA::Schema::Result::Item';

sub FROM_JSON { qw/id number name value scheduled.day_name/ }

1;
