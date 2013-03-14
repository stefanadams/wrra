use utf8;
package WRRA::Schema::Result::Bellcount;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

WRRA::Schema::Result::Bellcount

=cut

use strict;
use warnings;

=head1 BASE CLASS: L<WRRA::Schema::Result>

=cut

use base 'WRRA::Schema::Result';

=head1 TABLE: C<bellcount>

=cut

__PACKAGE__->table("bellcount");

=head1 ACCESSORS

=head2 bidder_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 bellitem_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 qty

  data_type: 'integer'
  default_value: 1
  extra: {unsigned => 1}
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "bidder_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "bellitem_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "qty",
  {
    data_type => "integer",
    default_value => 1,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</bidder_id>

=item * L</bellitem_id>

=back

=cut

__PACKAGE__->set_primary_key("bidder_id", "bellitem_id");


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-03-13 14:11:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jV8ygNaT0GDR1BSpuuoDpA

sub id { shift->bellcount_id }

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
