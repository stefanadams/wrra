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

use Data::Dumper;

# Set the result_class at the same time as the resultset
sub resultset {
	my $self = shift;
	my $source = pop @_;
	my $class = pop @_;
	$self = $self->SUPER::resultset($source);
	if ( $class ) {
		my $result_class = $self->result_class;
		$result_class =~ s/::Result::/::ResultClass::/;
		$result_class =~ s/([^:]+)$/$class/;
		$self = $self->search({}, {result_class => $result_class}) if $result_class->can('load_components');
	}
	$self->can('base') ? $self->base : $self
}

sub year {
	my $self = shift;
	$self->{__WRRA_YEAR} = $_[0] if $_[0];
	return $self->{__WRRA_YEAR} || ((localtime())[5])+1900;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
