package WRRA::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces(
    default_resultset_class => 'ResultSet',
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-11-16 09:09:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wM5zCfXKD5Qnd99BQCHs2w

our $year;
our $_warn;
sub year {
	my $self = shift;
	$year = $_[0] if $_[0];
	return $year if $year;
	unless ( $_warn ) {
		warn "No year defined, using current year\n";
		$_warn=1;
	}
	return ((localtime())[5])+1900;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
