package WRRA::Schema::Result::AcPayNumber;

use base 'WRRA::Schema::Result::Item';

sub _colmodel { qw/label desc name highbid.bidder.address csz/ }
sub label { shift->number }
sub desc { shift->name }
sub csz { join ', ', map { eval { $_[0]->highbid->bidder->$_ } } qw/city state zip/ }

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({-or => ['number'=>$req->{term},'name'=>{'like' => '%'.$req->{term}.'%'}]}, {prefetch=>'highbid',group_by=>'number', order_by=>'number'})->current_year
}

1;
