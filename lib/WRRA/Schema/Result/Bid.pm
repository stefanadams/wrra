use utf8;
package WRRA::Schema::Result::Bid;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

WRRA::Schema::Result::Bid

=cut

use strict;
use warnings;

=head1 BASE CLASS: L<WRRA::Schema::Result>

=cut

use base 'WRRA::Schema::Result';

=head1 TABLE: C<bids>

=cut

__PACKAGE__->table("bids");

=head1 ACCESSORS

=head2 bid_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 bidder_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 item_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 bid_r

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 bid

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 bidtime

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "bid_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "bidder_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "item_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "bid_r",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "bid",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "bidtime",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</bid_id>

=back

=cut

__PACKAGE__->set_primary_key("bid_id");


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-03-13 14:11:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bN9L2BvXIbFA/5ZjADlxCw

__PACKAGE__->belongs_to(bidder => 'WRRA::Schema::Result::Bidder', 'bidder_id');
__PACKAGE__->belongs_to(item => 'WRRA::Schema::Result::Item', 'item_id');

sub id { shift->bid_id }

sub bidage {
	my $self = shift;
	my $datetime = $self->result_source->schema->controller->datetime->clone;
	my $bidtime = $self->bidtime;
	return 'More than a day' if $datetime->epoch - $bidtime->epoch > 60*60*24;
	return join ':', map { sprintf '%02d', $_ } $datetime->subtract_datetime($bidtime)->in_units(qw/hours minutes seconds/);
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
