use utf8;
package WRRA::Schema::Result::Adcount;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

WRRA::Schema::Result::Adcount

=cut

use strict;
use warnings;

=head1 BASE CLASS: L<WRRA::Schema::Result>

=cut

use base 'WRRA::Schema::Result';

=head1 TABLE: C<adcount>

=cut

__PACKAGE__->table("adcount");

=head1 ACCESSORS

=head2 ad_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 processed

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 rotate

  data_type: 'integer'
  default_value: 1
  extra: {unsigned => 1}
  is_nullable: 1

=head2 display

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

=head2 click

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "ad_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "processed",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "rotate",
  {
    data_type => "integer",
    default_value => 1,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "display",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "click",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</ad_id>

=item * L</processed>

=back

=cut

__PACKAGE__->set_primary_key("ad_id", "processed");


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-03-13 14:11:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uZ7lnSEnilpGfft/9Fag0A

__PACKAGE__->belongs_to(ad => 'WRRA::Schema::Result::Ad', 'ad_id', {join_type=>''});       
sub id { shift->adcount_id }

sub processed {
        my $self = shift;
        $self->processed ? $self->processed : undef;
}

sub rotate {
        my $self = shift;
        $self->adcount->processed ? $self->adcount->rotate : undef;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
