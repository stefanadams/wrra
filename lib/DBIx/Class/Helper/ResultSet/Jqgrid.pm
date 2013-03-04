package DBIx::Class::Helper::ResultSet::Jqgrid;
{
  $DBIx::Class::Helper::ResultSet::Jqgrid::VERSION = '0.1.0';
}

use strict;
use warnings;

# This resultset method loads replacement create, search, update, and delete methods and returns the resultset object $self.
sub jqgrid {
	my $self = shift;
	return {
		page => $self->pager->current_page||1,
		total => $self->pager->last_page||1,
		records => $self->pager->total_entries||0,
		rows => [$self->all], # TO_JSON
	};
}

1;
