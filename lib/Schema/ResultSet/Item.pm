package Schema::ResultSet::Item;

use base 'Schema::ResultSet';

sub sold { $_[0]->search({($_[1]?"$_[1].sold":'sold') => {'!=' => undef}}) }

sub bankreport {
	my $self = shift;

	@_ = ();
	foreach my $record ( $self->search({}, {order_by=>{-asc=>['cast(sold as date)', 'number']}, prefetch=>['highbid']}) ) {
		push @_, [$record->sold->day_name, $record->number, $record->name, $record->highbid->bid, $record->highbid->bidder];
	}
	return [@_];
}

1;
