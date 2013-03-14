use utf8;
package WRRA::Schema::Result::Stockitem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

WRRA::Schema::Result::Stockitem

=cut

use strict;
use warnings;

=head1 BASE CLASS: L<WRRA::Schema::Result>

=cut

use base 'WRRA::Schema::Result';

=head1 TABLE: C<stockitems>

=cut

__PACKAGE__->table("stockitems");

=head1 ACCESSORS

=head2 stockitem_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 year

  data_type: 'year'
  is_nullable: 1

=head2 category

  data_type: 'set'
  extra: {list => ["food","gc","travel","personal care","auto","apparel","sports","event tickets","baskets","wine","misc","garden","one per","restaurant","catering","floral","spa","golf","meat","car wash","droege","kr"]}
  is_nullable: 1

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 value

  data_type: 'integer'
  is_nullable: 0

=head2 cost

  data_type: 'decimal'
  is_nullable: 0
  size: [10,2]

=cut

__PACKAGE__->add_columns(
  "stockitem_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "year",
  { data_type => "year", is_nullable => 1 },
  "category",
  {
    data_type => "set",
    extra => {
      list => [
        "food",
        "gc",
        "travel",
        "personal care",
        "auto",
        "apparel",
        "sports",
        "event tickets",
        "baskets",
        "wine",
        "misc",
        "garden",
        "one per",
        "restaurant",
        "catering",
        "floral",
        "spa",
        "golf",
        "meat",
        "car wash",
        "droege",
        "kr",
      ],
    },
    is_nullable => 1,
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "value",
  { data_type => "integer", is_nullable => 0 },
  "cost",
  { data_type => "decimal", is_nullable => 0, size => [10, 2] },
);

=head1 PRIMARY KEY

=over 4

=item * L</stockitem_id>

=back

=cut

__PACKAGE__->set_primary_key("stockitem_id");


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-03-13 14:11:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:N9+eXe3Erqfrq0LTL+ePeg

__PACKAGE__->has_many(items => 'WRRA::Schema::Result::Item', 'stockitem_id', {join_type=>''});
sub id { shift->stockitem_id }

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
