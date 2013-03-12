package WRRA::Schema::Result::AcBellitem;

use base 'WRRA::Schema::Result::Bellitem';

sub _colmodel { qw/label id/ }
sub label { shift->name }

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({name=>{'like' => $req->{term}.'%'}}, {group_by=>'name', order_by=>'name'})->current_year
}

1;
