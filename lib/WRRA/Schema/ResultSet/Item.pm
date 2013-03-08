package WRRA::Schema::ResultSet::Item;

use base 'WRRA::Schema::ResultSet';

sub sold { $_[0]->search({$_[0]->me.'sold' => {'!=' => undef}}) }
sub not_sold { $_[0]->search({$_[0]->me.'sold' => {'=' => undef}}) }

1;
