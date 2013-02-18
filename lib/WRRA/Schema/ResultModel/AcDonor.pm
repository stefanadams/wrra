package WRRA::Schema::ResultModel::AcDonor;

use base 'WRRA::Schema::Result::Donor';

#sub label {
#	my $self = shift;
#	join ':', $self->name, $self->donor_id;
#}
#sub TO_JSON { shift->hashref(qw(label advertisement)) }

sub TO_JSON {
	my $self = shift;
	return {  
		label => $self->nameid,
		advertisement => $self->advertisement,
	};
}

1;
