package WRRA::Schema::ResultView::ResultSet::AcItemCurrent;

sub default {
	my ($self, $req) = @_;
	$self->search({-or => ['me.number'=>$req->{term},'me.name'=>{'like' => '%'.$req->{term}.'%'}]}, {group_by=>'me.name', order_by=>'me.name'})->current_year
}

1;
