package WRRA::Schema::Result::Ads;

use base 'WRRA::Schema::Result::Ad';

sub _colmodel { qw/id name scheduled.day_name advertiser.nameid url/ }

sub _create {
        my ($class, $r, $rs, $req) = @_;
        $r->year($rs->datetime->year);
        return $r;
};
sub _search { $_[1]->current_year } 

our $relationships = 'advertiser';

our $read = {
        'scheduled.day_name' => 'scheduled',
	'advertiser.nameid' => 'advertiser.name',
};
our $edit = {
        'scheduled.day_name' => sub {
		return scheduled => shift;
	},
        'advertiser.nameid' => sub {
                my (undef, $id) = (shift =~ /(.*?):([^:]+)$/);
                return advertiser_id => $id||'';
        },
};

1;
