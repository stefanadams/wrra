package DBIx::Class::Helper::Row::Crud;
{
  $DBIx::Class::Helper::Row::Crud::VERSION = '0.1.0';
}

sub TO_JSON {
        my $self = shift;

        return () unless $self->can('_colmodel');

        my %tables = ();
        foreach ( grep { /\./ } $self->_colmodel ) {
                my ($table, $field) = split /\./;
                if ( $self->can($table) && defined $self->$table ) {
                        if ( $self->$table->can($field) && defined $self->$table->$field ) {
                                $tables{$table}{$field} = $self->$table->$field;
                        } else {
                                $tables{$table}{$field} = '';
                        }
                } elsif ( not exists $tables{$table} ) {
                        $tables{$table} = undef;
                }
        }
        warn Data::Dumper::Dumper({%tables}) if $ENV{COLMODEL_DEBUG};
        return { (map { $_ => $self->$_ } grep { !/\./ } $self->_colmodel), (%tables) };
}

sub TO_XLS {
        my $self = shift;

        return () unless $self->can('_colmodel');

        my %tables = ();
	my @row = ();
        foreach ( $self->_colmodel ) {
		if ( /\./ ) {
	                my ($table, $field) = split /\./;
        	        if ( $self->can($table) && defined $self->$table ) {
                	        if ( $self->$table->can($field) && defined $self->$table->$field ) {
					push @row, $self->$table->$field;
                                	$tables{$table}{$field} = $self->$table->$field;
	                        } else {
					push @row, undef;
                	                $tables{$table}{$field} = '';
                        	}
	                } elsif ( not exists $tables{$table} ) {
				push @row, undef;
                	        $tables{$table} = undef;
	                }
		} else {
			push @row, $self->can($_) ? $self->$_ : undef;
		}
        }
        warn Data::Dumper::Dumper([@row]) if $ENV{COLMODEL_DEBUG};
	return [@row];
}

1;
