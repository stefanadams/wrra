package WRRA::Schema::ResultModel::AcAdvertiser;

use base 'WRRA::Schema::Result::Donor';

sub TO_JSON {
	my $self = shift;
	return {  
		ad => $self->nameid,
		label => $self->nameid,
		(map { $_ => $self->$_ } qw(url)),
	};
}

1;
