package DBIx::Class::Helper::ResultSet::Jqgrid;
{
  $DBIx::Class::Helper::ResultSet::Jqgrid::VERSION = '0.1.0';
}

use strict;
use warnings;

# This resultset method loads replacement create, search, update, and delete methods and returns the resultset object $self.
sub jqgrid {
	my $self = shift;
	(ref $self)->load_components(qw{Helper::ResultSet::Jqgrid::RSMethods});
	$self;
}

1;
