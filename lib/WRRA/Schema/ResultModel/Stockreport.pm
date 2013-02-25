package WRRA::Schema::ResultModel::Stockreport;

use base 'WRRA::Schema::Result::Stockitem';

sub TO_XLS { shift->arrayref(qw(soldday name highbid)) }
sub TO_JSON {
	my $self = shift;
	return {
		name => $self->name,
		count => $self->get_column('count'),
		value => $self->get_column('tvalue'),
		cost => $self->get_column('tcost'),
	};
}

1;
