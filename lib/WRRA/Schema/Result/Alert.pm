use utf8;
package WRRA::Schema::Result::Alert;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

WRRA::Schema::Result::Alert

=cut

use strict;
use warnings;

=head1 BASE CLASS: L<WRRA::Schema::Result>

=cut

use base 'WRRA::Schema::Result';

=head1 TABLE: C<alerts>

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

=head1 PRIMARY KEY

=over 4

=item * L</alert>

=back

=cut

__PACKAGE__->set_primary_key("alert");


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-03-13 14:11:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:E7x7Y4q1j0uTXoCnQKcVXA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
