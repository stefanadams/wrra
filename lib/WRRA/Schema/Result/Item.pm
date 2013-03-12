package WRRA::Schema::Result::Item;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'WRRA::Schema::Result';

=head1 NAME

WRRA::Schema::Result::Item

=cut

__PACKAGE__->table("items");

=head1 ACCESSORS

=head2 item_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 year

  data_type: 'year'
  is_nullable: 1

=head2 seq

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 number

  data_type: 'integer'
  is_nullable: 1

=head2 category

  data_type: 'set'
  extra: {list => ["food","gc","travel","personal care","auto","apparel","sports","event tickets","baskets","wine","misc","garden","one per","restaurant","catering","floral","spa","golf","meat","car wash","droege","kr"]}
  is_nullable: 1

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 value

  data_type: 'integer'
  is_nullable: 1

=head2 highbid_id

  data_type: 'integer'
  is_nullable: 1

=head2 bellitem_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 auctioneer

  data_type: 'enum'
  extra: {list => ["a","b"]}
  is_nullable: 1

=head2 notify

  data_type: 'set'
  extra: {list => ["newbid","starttimer","stoptimer","holdover","sell"]}
  is_nullable: 1

=head2 url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 donor_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 stockitem_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 scheduled

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 started

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 timer

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 sold

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 cleared

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 contacted

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "item_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "year",
  { data_type => "year", is_nullable => 1 },
  "seq",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "number",
  { data_type => "integer", is_nullable => 1 },
  "category",
  {
    data_type => "set",
    extra => {
      list => [
        "food",
        "gc",
        "travel",
        "personal care",
        "auto",
        "apparel",
        "sports",
        "event tickets",
        "baskets",
        "wine",
        "misc",
        "garden",
        "one per",
        "restaurant",
        "catering",
        "floral",
        "spa",
        "golf",
        "meat",
        "car wash",
        "droege",
        "kr",
      ],
    },
    is_nullable => 1,
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "value",
  { data_type => "integer", is_nullable => 1 },
  "highbid_id",
  { data_type => "integer", is_nullable => 1 },
  "bellitem_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "auctioneer",
  { data_type => "enum", extra => { list => ["a", "b"] }, is_nullable => 1 },
  "notify",
  {
    data_type => "set",
    extra => {
      list => ["newbid", "starttimer", "stoptimer", "holdover", "sell"],
    },
    is_nullable => 1,
  },
  "url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "donor_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "stockitem_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "scheduled",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "started",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "timer",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "sold",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "cleared",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "contacted",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);
__PACKAGE__->set_primary_key("item_id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-11-17 16:47:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zzBrNP/WiSzWNNMfSNjxXA

#belongs to means the fk is in your own table, and might have/has_many/has_one means the fk points to you, and is in the other table
__PACKAGE__->belongs_to(donor => 'WRRA::Schema::Result::Donor', 'donor_id', {join_type=>'left'}); # An Item belongs_to a Donor, join to Donor via donor_id
__PACKAGE__->belongs_to(stockitem => 'WRRA::Schema::Result::Stockitem', 'stockitem_id', {join_type=>'left'}); # An Item belongs_to Stockitem, join to Stockitem via stockitem_id
__PACKAGE__->belongs_to(highbid => 'WRRA::Schema::Result::Bid', {'foreign.bid_id'=>'self.highbid_id'}, {join_type=>'left'}); # An Item belongs_to a particular highbid
__PACKAGE__->has_many(bids => 'WRRA::Schema::Result::Bid', 'item_id', {join_type=>'left'}); # An Item has_many bids, join to Bid via item_id
__PACKAGE__->many_to_many(bidders => 'bids', 'bidder'); # An Item is bid on by many Bidders, bridge to bidders via Bid's bidder

sub id { shift->item_id }

#sub itemcat {
#	my $self = shift;
#	('food','gc','travel','personal care','auto','apparel','sports','event tickets','baskets','wine','misc','garden','one per','restaurant','catering','floral','spa','golf','meat','car wash','droege','kr');
#}

#sub auctioneer {
#	my $self = shift;
#	('a','b');
#}

#sub notify {
#	my $self = shift;
#	('newbid','starttimer','stoptimer','holdover','sell');
#}

sub status {
	my $self = shift;
	my $status = {map {$_=>ref $self->$_?1:defined $self->$_?$self->$_:undef} qw/scheduled started timer sold cleared contacted auctioneer/};
	return 'Complete'  if  $status->{scheduled}   &&           1              &&  $status->{started}   &&  $status->{sold}   &&  $status->{cleared};
	return 'Sold'      if  $status->{scheduled}   &&           1              &&  $status->{started}   &&  $status->{sold}   && !$status->{cleared};
	return 'Bidding'   if  $status->{scheduled}   &&  $status->{auctioneer}   &&  $status->{started}   && !$status->{sold};# && !$status->{cleared};
	return 'OnDeck'    if  $status->{scheduled}   &&  $status->{auctioneer}   && !$status->{started};# && !$status->{sold}   && !$status->{cleared};
	return 'Ready'     if  $status->{scheduled}   && !$status->{auctioneer};# && !$status->{started}   && !$status->{sold}   && !$status->{cleared};
	return 'Not Ready' if !$status->{scheduled};# && !$status->{auctioneer}   && !$status->{started}   && !$status->{sold}   && !$status->{cleared};
	return 'Unknown';
}

sub startbid {
	my $self = shift;
	return 5 if $self->value < 100;
	return 50 if $self->value < 250;
	return 100;
}

sub minbid {
	my $self = shift;
	return undef unless $self->can('highbid');
	return $self->startbid unless ref $self->highbid;
	return undef unless $self->highbid->can('bid');
	return $self->highbid->bid+5 if $self->highbid->bid < $self->value;
	return $self->highbid->bid+1;
}

sub cansell {
	my $self = shift;
	return undef if !ref $self->timer || ref $self->sold;
	return time-$self->timer->epoch > 5*60 ? 1 : 0;
}

sub bellringer {
	my $self = shift;
	return undef unless $self->can('highbid') && ref $self->highbid;
	return undef unless $self->highbid->can('bid');
	return $self->highbid->bid >= $self->value ? 1 : undef;
}

sub runningtime {
	my $self = shift;
	return undef unless ref $self->started;
	return time-$self->started->epoch;
}

sub timerminutes {
	my $self = shift;
	return undef unless ref $self->timer;
	return time-$self->timer->epoch;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
