package DBIx::Class::Helper::ResultSet::MyRequest;
{
  $DBIx::Class::Helper::ResultSet::MyRequest::VERSION = '0.1.0';
}

use strict;
use warnings;

our $myrequest;
our $_myrequest;

# The first call to ->myrequest stores the passed parameters into class variable $_myrequest and returns the resultset object $self
# ALL subsequent requests return the stored parameters from the initial call
sub myrequest {
	my $self = shift;
	return $myrequest if $_myrequest;
	$_myrequest = 1;
	$myrequest = ref $_[0] ? $_[0] : {@_};
	return $self;
}

1;
