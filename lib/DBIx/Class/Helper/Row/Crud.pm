package DBIx::Class::Helper::Row::Crud;
{
  $DBIx::Class::Helper::Row::Crud::VERSION = '0.1.0';
}

use Mojo::JSON;

sub TO_JSON {
        my $self = shift;

        return () unless $self->can('_colmodel');

        my %tables = my %tables1 = ();
        foreach ( grep { /\./ } $self->_colmodel ) {
                my ($table, @field) = split /\./;
		my $f1 = my $f2 = join '.', @field;
		$f1 =~ s/\./\}\{/g;
		$f2 =~ s/\./->/g;
		eval "\$tables1{$table}{$f1} = \$self->$table->$f2";
        }
        warn Data::Dumper::Dumper({%tables1}) if $ENV{COLMODEL_DEBUG};
        return { (map { $_ => $self->$_ } grep { !/\./ } $self->_colmodel), (%tables1) };
}

sub TO_XLS {
        my $self = shift;

        return () unless $self->can('_colmodel');

        my %tables = ();
	my @row = ();
        foreach ( grep { /\./ } $self->_colmodel ) {
                my ($table, @field) = split /\./;
		my $f1 = my $f2 = join '.', @field;
		$f1 =~ s/\./\}\{/g;
		$f2 =~ s/\./->/g;
		eval "push \@row, \$self->$table->$f2";
        }
        warn Data::Dumper::Dumper([@row]) if $ENV{COLMODEL_DEBUG};
	return [(map { $self->$_ } grep { !/\./ } $self->_colmodel), @row];
}

1;
