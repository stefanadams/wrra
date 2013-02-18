package WRRA::Schema::ResultSet::Rotarian;
use base 'WRRA::Schema::ResultSet';

sub leaders { $_[0]->search({'lead' => 1}) }

1;
