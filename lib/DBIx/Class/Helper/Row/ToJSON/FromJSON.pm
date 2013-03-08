package DBIx::Class::Helper::Row::ToJSON::FromJSON;
{
  $DBIx::Class::Helper::Row::ToJSON::FromJSON::VERSION = '0.1.0';
}

use base qw/DBIx::Class::Helper::Row::ToJSON/;

sub TO_JSON {
        my $self = shift;
        warn ref($self)." TO_JSON!\n" if $ENV{JSON_DEBUG};

	return $self->SUPER::TO_JSON unless $self->can('FROM_JSON');

	my %tables = ();
	foreach ( grep { /\./ } $self->FROM_JSON ) {
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
	warn Data::Dumper::Dumper({%tables}) if $ENV{JSON_DEBUG};
        return { (map { $_ => $self->$_ } grep { !/\./ } $self->FROM_JSON), (%tables) };
}

1;
