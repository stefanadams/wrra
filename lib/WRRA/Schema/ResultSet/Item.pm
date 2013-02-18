package WRRA::Schema::ResultSet::Item;

use base 'WRRA::Schema::ResultSet';

sub sold { $_[0]->search({sold => {'!=' => undef}}) }

sub next_year { $_[0]->search({year => $_[0]->year+1}) }
sub current_year { $_[0]->search({$_[0]->current_source_alias.'.year' => $_[0]->year}) }
sub last_year { $_[0]->search({year => $_[0]->year-1}) } 
sub recent_years { $_[0]->search({year => {-between => [$_[0]->year-2, $_[0]->year]}}) }

1;
