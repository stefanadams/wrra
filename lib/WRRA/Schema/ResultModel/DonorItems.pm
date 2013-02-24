package WRRA::Schema::ResultModel::DonorItems;

use base 'WRRA::Schema::Result::Item';

sub TO_XLS { shift->arrayref(qw(year sold value highbid.bid bellringer)) }
sub TO_JSON {
	my $self = shift;
	return {
		(map { $_ => $self->$_ } qw(year value bellringer)),   
		sold => $self->sold->day_name,
		highbid => {
			bid => $self->eval('$self->highbid->bid'),
		},
	};
}

1;
