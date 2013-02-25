package WRRA::Schema::ResultSet::Stockitem;
use base 'WRRA::Schema::ResultSet';

sub next_year { $_[0]->search({($_[1]?"$_[1].year":'year') => $_[0]->year+1}) }    
sub current_year { $_[0]->search({$_[0]->current_source_alias.'.year' => $_[0]->year}) }
sub last_year { $_[0]->search({($_[1]?"$_[1].year":'year') => $_[0]->year-1}) }    
sub recent_years { $_[0]->search({($_[1]?"$_[1].year":'year') => {-between => [$_[0]->year-2, $_[0]->year]}}) }   

1;
