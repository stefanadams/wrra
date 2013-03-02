package WRRA::Schema::ResultView::Result::Items;

sub TO_VIEW { qw/id number donor.id donor.nameid donor.advertisement stockitem.id stockitem.nameid name description value category url/ }

1;

__END__
# See Cookbook : Wrapping/overloading_a_column_accessor
# This might be for when updating a column that doesn't exist
#__PACKAGE__->add_columns(name => { accessor => '_name' });
#__PACKAGE__->add_columns(number => { accessor => '_number' });
