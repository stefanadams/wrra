package WRRA::Schema::ResultModel::AcAd;

use base 'WRRA::Schema::Result::Ad';

sub TO_JSON {
	my $self = shift;
	return {  
		label => $self->nameid,
		(map { $_ => $self->$_ } qw(url)),
	};
}

1;
