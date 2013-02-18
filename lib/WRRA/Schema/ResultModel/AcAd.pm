package WRRA::Schema::ResultModel::AcAd;

use base 'WRRA::Schema::Result::Ad';

sub ad {
	my $self = shift;
	join ':', $self->SUPER::ad->name, $self->SUPER::ad->ad_id;
}

sub TO_JSON { shift->hashref(qw(url ad)) }

1;
