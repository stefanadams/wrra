package Schema::ResultSet::Rotarian;

use base 'Schema::ResultSet';

sub leaders { $_[0]->search({$_[0]->current_source_alias.'.lead' => 1}) }

1;
