package Schema::Result::Alert;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Schema::Result';

__PACKAGE__->load_components("InflateColumn::DateTime", "Helper::Row::ToJSON");

=head1 NAME

Schema::Result::Alert

=cut

__PACKAGE__->table("alerts");

=head1 ACCESSORS

=head2 alert

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=head2 msg

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "alert",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "msg",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("alert");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-11-17 16:47:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lCTqUyPSJEV6Haiiu/Ze3Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
