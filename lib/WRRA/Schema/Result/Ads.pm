package WRRA::Schema::Result::Ads;

use base 'WRRA::Schema::Result::Ad';

sub _colmodel { qw/name scheduled.day_name advertiser.nameid url/ }

sub _search { $_[1]->current_year } 

1;
