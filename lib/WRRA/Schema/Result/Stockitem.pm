package WRRA::Schema::Result::Stockitem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'WRRA::Schema::Result';

=head1 NAME

WRRA::Schema::Result::Stockitem

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
__PACKAGE__->set_primary_key("stockitem_id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-11-17 16:47:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Go27bSSHdTSYkFdGPp2zhA

__PACKAGE__->has_many(items => 'WRRA::Schema::Result::Item', 'stockitem_id', {join_type=>''});
sub id { shift->stockitem_id }

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
