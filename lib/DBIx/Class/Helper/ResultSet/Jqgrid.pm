package DBIx::Class::Helper::ResultSet::Jqgrid;
{
  $DBIx::Class::Helper::ResultSet::Jqgrid::VERSION = '0.1.0';
}

use strict;
use warnings;

use Data::Dumper;

# This resultset method loads replacement create, search, update, and delete methods and returns the resultset object $self.
sub jqgrid {
	my $self = shift;
	my $resultset_class = $self->result_source->resultset_class;
	$resultset_class->load_components(qw{Helper::ResultSet::Jqgrid::RSMethods});
	$self;
}

1;
