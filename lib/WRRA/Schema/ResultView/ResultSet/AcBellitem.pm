package WRRA::Schema::ResultView::ResultSet::AcBellitem;

sub default {
	my ($self, $req) = @_;
	$self->search({-or => [city=>{'like' => $req->{term}.'%'}, state=>{'like' => $req->{term}.'%'}, zip=>{'like' => $req->{term}.'%'}]}, {group_by=>'name', order_by=>'name'})->current_year
}

1;
