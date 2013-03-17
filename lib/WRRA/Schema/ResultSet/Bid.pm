package WRRA::Schema::ResultSet::Bid;
use base 'WRRA::Schema::ResultSet';

#sub next_year { $_[0]->search({($_[1]?"$_[1].year":'year') => $_[0]->year+1}) }    
#sub current_year { $_[0]->search({($_[1]?"$_[1].year":'year') => $_[0]->year}) }   
#sub last_year { $_[0]->search({($_[1]?"$_[1].year":'year') => $_[0]->year-1}) }    
#sub recent_years { $_[0]->search({($_[1]?"$_[1].year":'year') => {-between => [$_[0]->year-2, $_[0]->year]}}) }   

sub bids {
	my $self = shift;
	@_ = ();
	foreach ( $self->all ) {
		push @_, {
			bid => $_->bid,
			name => $_->bidder->name,
		}
	}
	return [@_]
}

1;
