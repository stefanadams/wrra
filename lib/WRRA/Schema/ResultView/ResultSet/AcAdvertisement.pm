package WRRA::Schema::ResultView::ResultSet::AcAdvertisement;

sub default {
	my ($self, $req) = @_;
	$self->search({-or => [donor_id=>$req->{term}, advertisement=>{'like' => '%'.$req->{term}.'%'}]}, {group_by=>'advertisement', order_by=>'advertisement'})
}

1;
