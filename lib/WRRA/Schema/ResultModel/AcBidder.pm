package WRRA::Schema::ResultModel::AcBidder;

use base 'WRRA::Schema::Result::Bidder';

sub TO_JSON {
	my $self = shift;
	return {  
		label => $self->nameid,
		desc => $self->phone,
	};
}

1;
