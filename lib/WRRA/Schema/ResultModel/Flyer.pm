package WRRA::Schema::ResultModel::Flyer;

use base 'WRRA::Schema::Result::Item';

sub TO_XLS {
	my $self = shift;
	return [
		(map { $self->$_ } qw(name value)),
		$self->eval('$self->scheduled->day_name'),
	];
}
sub TO_JSON {
	my $self = shift;
	return {
		(map { $_ => $self->$_ } qw(name value)),
		scheduled => $self->eval('$self->scheduled->day_name'),
	};
}

1;
