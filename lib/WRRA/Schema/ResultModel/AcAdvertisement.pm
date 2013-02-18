package WRRA::Schema::ResultModel::AcAdvertisement;

use base 'WRRA::Schema::Result::Donor';

sub label { shift->advertisement }

sub TO_JSON { shift->hashref(qw(label)) }

1;
