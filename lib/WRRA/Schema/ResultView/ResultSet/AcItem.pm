package WRRA::Schema::ResultView::ResultSet::AcItem;

sub default {
	my ($self, $req) = @_;
	$self->search({-or => ['me.number'=>$req->{term},'me.name'=>{'like' => '%'.$req->{term}.'%'}, 'donor.name'=>{'like' => '%'.$req->{term}.'%'}]}, {group_by=>'name', order_by=>'name'})->recent_years
}

1;
