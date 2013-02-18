package WRRA::Schema::ResultModel::AcCity;

use base 'WRRA::Schema::Result::Donor';

sub label { shift->city }

sub TO_JSON { shift->hashref(qw(label state zip)) }

1;
