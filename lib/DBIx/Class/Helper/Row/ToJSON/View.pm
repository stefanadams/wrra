package DBIx::Class::Helper::Row::ToJSON::View;
{
  $DBIx::Class::Helper::Row::ToJSON::View::VERSION = '0.1.0';
}

use strict;
use warnings;

use base 'DBIx::Class::Helper::Row::ToJSON';

sub TO_JSON {
        my $self = shift;
        warn ref($self)." TO_JSON!\n" if $ENV{VIEW_DEBUG};

	return $self->SUPER::TO_JSON unless $self->can('TO_VIEW');

	my %tables = ();
	foreach ( grep { /\./ } $self->TO_VIEW ) {
		my ($table, $field) = split /\./;
		if ( $self->can($table) && defined $self->$table ) {
			if ( $self->$table->can($field) && defined $self->$table->$field ) {
				$tables{$table}{$field} = $self->$table->$field;
			} else {
				$tables{$table}{$field} = '';
			}
		} elsif ( not exists $tables{$table} ) {
			$tables{$table} = {};
		}
	}
	warn Data::Dumper::Dumper({%tables}) if $ENV{VIEW_DEBUG};
        return { (map { $_ => $self->$_ } grep { !/\./ } $self->TO_VIEW), (%tables) };
}

1;