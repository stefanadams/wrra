package WRRA::Schema::ResultView::ResultSet::AcBidder;

sub default {
	my ($self, $req) = @_;
	$self->search({-or => ['me.name'=>{'like' => $req->{term}.'%'}, 'me.bidder_id'=>$req->{term}]}, {group_by=>'me.bidder_id', order_by=>'me.name'})
}

1;
