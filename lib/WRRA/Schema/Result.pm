package WRRA::Schema::Result;

use base 'DBIx::Class::Core';
__PACKAGE__->load_components(qw/InflateColumn::DateTime Helper::Row::ToJSON::FromJSON/);

sub nameid { my $self = shift; join ':', $self->name, $self->id; }
sub _value { shift->value }

# Make this a component
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
