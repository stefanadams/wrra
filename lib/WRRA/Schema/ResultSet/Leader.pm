package WRRA::Schema::ResultSet::Leader;

use base 'WRRA::Schema::ResultSet';

sub leaders { $_[0]->search({$_[0]->current_source_alias.'.lead' => 1}) }

1;
