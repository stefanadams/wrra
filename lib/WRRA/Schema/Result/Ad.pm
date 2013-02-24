package WRRA::Schema::Result::Ad;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'WRRA::Schema::Result';

=head1 NAME

WRRA::Schema::Result::Ad

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
__PACKAGE__->set_primary_key("ad_id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-11-17 16:47:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:p0Re/k+OWF2/Y115mW5mbw

sub id { shift->ad_id }

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
