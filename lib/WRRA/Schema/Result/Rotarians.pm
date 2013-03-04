package WRRA::Schema::Result::Rotarians;

use base 'WRRA::Schema::Result::Rotarian';

sub _search {
	my ($self, $rs, $req) = @_;
	$rs;
} 

sub TO_VIEW { qw/id name has_submissions email phone/ }
sub _search_id { 'rotarian_id' }
sub _search_name { 'concat(lastname, firstname)' }
sub _order_by_name { \'concat(lastname, firstname)' }

1;

__END__
#__PACKAGE__->load_components(qw{Helper::Result::Jqgrid});
# See Cookbook : Wrapping/overloading_a_column_accessor
# This might be for when updating a column that doesn't exist
#__PACKAGE__->addTO_VIEW(name => { accessor => '_name' });
#__PACKAGE__->addTO_VIEW(number => { accessor => '_number' });
#sub _prefetch { ['donor','stockitem'] }
