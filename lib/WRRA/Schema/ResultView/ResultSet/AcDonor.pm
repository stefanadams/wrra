package WRRA::Schema::ResultView::ResultSet::AcDonor;

sub default {
	my ($self, $req) = @_;
	$self->search({-or => ['name'=>{'like' => '%'.$req->{term}.'%'}, 'donor_id'=>$req->{term}]}, {group_by=>'donor_id', order_by=>'name'})
}

1;
