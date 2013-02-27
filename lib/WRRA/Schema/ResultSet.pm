package WRRA::Schema::ResultSet;

use base qw/DBIx::Class::ResultSet::HashRef DBIx::Class::ResultSet/;

__PACKAGE__->load_components(qw(Helper::ResultSet::Me Helper::ResultSet::Jqgrid));

use strict;
use warnings;

sub year { shift->result_source->schema->year }

sub next_year { $_[0]->search({$_[0]->me.'year' => $_[0]->year+1}) }
sub current_year { $_[0]->search({$_[0]->me.'year' => $_[0]->year}) }
sub last_year { $_[0]->search({$_[0]->me.'year' => $_[0]->year-1}) }
sub recent_years { $_[0]->search({$_[0]->me.'year' => {-between => [$_[0]->year-2, $_[0]->year]}}) }

1;
