package WRRA::Schema::ResultModel::AcAdvertiser;

use base 'WRRA::Schema::Result::Donor';

sub advertiser {
	my $self = shift;
	join ':', $self->SUPER::ad->name, $self->SUPER::ad->ad_id;
}

sub TO_JSON { shift->hashref(qw(url advertiser)) }

1;
