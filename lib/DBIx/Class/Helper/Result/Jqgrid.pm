package DBIx::Class::Helper::Result::Jqgrid;
{
  $DBIx::Class::Helper::Result::Jqrid::VERSION = '0.1.0';
}

use strict;
use warnings;

use parent 'DBIx::Class';

sub _eval { my $self = shift; my $eval = eval($_[0]); return $@ ? '' : $eval }
sub TO_JSON {
        my $self = shift;
        warn ref($self)." TO_JSON!\n" if $ENV{JQGRID_DEBUG};

	my %tables = ();
	foreach ( grep { /\./ } $self->_columns ) {
		my ($table, $field) = split /\./;
		$tables{$table}{$field} = $self->_eval("\$self->$table->$field");
	}
	warn Data::Dumper::Dumper({%tables}) if $ENV{JQGRID_DEBUG};
        return { (map { $_ => $self->$_ } grep { !/\./ } $self->_columns), (%tables) };
}

1;
