package WRRA::Schema::Result;

use base 'DBIx::Class::Core';
__PACKAGE__->load_components(qw/InflateColumn::DateTime/);

1;
