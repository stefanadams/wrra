package WRRA::Schema::Result::AcBellitem;

use base 'WRRA::Schema::Result::Bellitem';

sub default {
	my ($self, $rs, $req) = @_;
	$rs->search({-or => [city=>{'like' => $req->{term}.'%'}, state=>{'like' => $req->{term}.'%'}, zip=>{'like' => $req->{term}.'%'}]}, {group_by=>'name', order_by=>'name'})->current_year
}

sub TO_VIEW { qw/id/ }

1;
