use utf8;
package WRRA::Schema::Result::Ad;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

WRRA::Schema::Result::Ad

=cut

use strict;
use warnings;

=head1 BASE CLASS: L<WRRA::Schema::Result>

=cut

use base 'WRRA::Schema::Result';

=head1 TABLE: C<ads>

=cut

__PACKAGE__->table("ads");

=head1 ACCESSORS

=head2 ad_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 year

  data_type: 'year'
  is_nullable: 1

=head2 scheduled

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 advertiser_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 url

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "ad_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "year",
  { data_type => "year", is_nullable => 1 },
  "scheduled",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "advertiser_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "url",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</ad_id>

=back

=cut

__PACKAGE__->set_primary_key("ad_id");


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-03-13 14:11:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:tB+/8I3AVoLlav5xq7K90Q

__PACKAGE__->has_many(adcount => 'WRRA::Schema::Result::Adcount', 'ad_id', {join_type=>'left'});
__PACKAGE__->belongs_to(advertiser => 'WRRA::Schema::Result::Donor',  {'foreign.donor_id'=>'self.advertiser_id'});
sub id { shift->ad_id }

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
