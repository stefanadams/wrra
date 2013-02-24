package WRRA::Schema::Result::Bid;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'WRRA::Schema::Result';

=head1 NAME

WRRA::Schema::Result::Bid

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
__PACKAGE__->set_primary_key("bid_id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-11-17 16:47:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Tffva72o0PeL1oZj7WgrlA

__PACKAGE__->belongs_to(bidder => 'WRRA::Schema::Result::Bidder', 'bidder_id');
__PACKAGE__->belongs_to(item => 'WRRA::Schema::Result::Item', 'item_id');

use overload '""' => sub { shift->bid }, fallback=>1;
sub id { shift->bid_id }

sub bidage {
	my $self = shift;
	return defined $self->bidtime ? $self->bidtime->can('epoch') ? time-$self->bidtime->epoch : undef : undef;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
