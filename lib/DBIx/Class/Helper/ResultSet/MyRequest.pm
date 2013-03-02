package DBIx::Class::Helper::ResultSet::MyRequest;
{
  $DBIx::Class::Helper::ResultSet::MyRequest::VERSION = '0.1.0';
}

use strict;
use warnings;

# The first call to ->myrequest stores the passed parameters into instance key _myrequest and returns the resultset object $self
# ALL subsequent requests return the stored parameters from the initial call
sub myrequest {
	my $self = shift;
	exists $self->{_myrequest} and return $self->{_myrequest};
	$self->{_myrequest} = ref $_[0] ? $_[0] : {@_};
	return $self;
}

1;
