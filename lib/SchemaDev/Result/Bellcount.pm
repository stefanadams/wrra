package Schema::Result::Bellcount;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Schema::Result';

__PACKAGE__->load_components("InflateColumn::DateTime", "Helper::Row::ToJSON");

=head1 NAME

Schema::Result::Bellcount

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
__PACKAGE__->set_primary_key("bidder_id", "bellitem_id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-11-17 16:47:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:oAyNFrYeEDfqYnlVlpQbBw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
