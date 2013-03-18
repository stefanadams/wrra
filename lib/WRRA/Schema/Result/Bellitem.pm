use utf8;
package WRRA::Schema::Result::Bellitem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

WRRA::Schema::Result::Bellitem

=cut

use strict;
use warnings;

=head1 BASE CLASS: L<WRRA::Schema::Result>

=cut

use base 'WRRA::Schema::Result';

=head1 TABLE: C<bellitems>

=cut

__PACKAGE__->table("bellitems");

=head1 ACCESSORS

=head2 bellitem_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 year

  data_type: 'year'
  is_nullable: 1

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "bellitem_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "year",
  { data_type => "year", is_nullable => 1 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</bellitem_id>

=back

=cut

__PACKAGE__->set_primary_key("bellitem_id");


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-03-13 14:11:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:t6Ekp8t8snD8ySNiUgL7pg

__PACKAGE__->has_many(items => 'WRRA::Schema::Result::Item', 'bellitem_id', {join_type=>''});
sub id { shift->bellitem_id }

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
