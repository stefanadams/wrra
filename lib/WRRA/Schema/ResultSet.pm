package WRRA::Schema::ResultSet;

use base qw/DBIx::Class::ResultSet::HashRef DBIx::Class::ResultSet/;

__PACKAGE__->load_components(qw(Helper::ResultSet::Me Helper::ResultSet::Mojolicious Helper::ResultSet::Jqgrid));

use strict;
use warnings;

sub year { $_[0]->search({($_[1]?"$_[1].year":$_[0]->me.'year') => $_[2]||$_[0]->session->{year}}) }
sub next_year { $_[0]->search({($_[1]?"$_[1].year":$_[0]->me.'year') => $_[0]->session->{year}+1}) }
sub current_year { $_[0]->search({($_[1]?"$_[1].year":$_[0]->me.'year') => $_[0]->session->{year}}) }
sub last_year { $_[0]->search({($_[1]?"$_[1].year":$_[0]->me.'year') => $_[0]->session->{year}-1}) }
sub recent_years { $_[0]->search({($_[1]?"$_[1].year":$_[0]->me.'year') => {-between => [$_[0]->session->{year}-$_[0]->session->{recent_years}+1, $_[0]->session->{year}]}}) }

1;
