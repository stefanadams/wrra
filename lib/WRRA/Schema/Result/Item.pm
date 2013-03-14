use utf8;
package WRRA::Schema::Result::Item;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

WRRA::Schema::Result::Item

=cut

use strict;
use warnings;

=head1 BASE CLASS: L<WRRA::Schema::Result>

=cut

use base 'WRRA::Schema::Result';

=head1 TABLE: C<items>

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

Covers ALL nights; one big incremental

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

=head2 notifications

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
  "notifications",
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

=head1 PRIMARY KEY

=over 4

=item * L</item_id>

=back

=cut

__PACKAGE__->set_primary_key("item_id");


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-03-13 14:11:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+riHy43WHIUGqRWS4gjM1g

use 5.010;

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

# Extended Accessors

use constant {
	COMPLETED => 70,
	VERIFY => 60,
	SOLD => 50,
	BIDDING => 40,
	ON_DECK => 30,
	READY => 20,
	NOT_READY => 10,
	UNKNOWN => undef,
};
use constant {
	TRUE => 1,
	FALSE => 0,
};
use constant {
	MINUTES => 60,
	DOLLARS => 1,
};

sub status {
	my $self = shift;
	return COMPLETED if  $self->scheduled   &&           1          &&  $self->started   &&  $self->sold   &&  $self->cleared   &&  $self->contacted;
	return VERIFY    if  $self->scheduled   &&           1          &&  $self->started   &&  $self->sold   &&  $self->cleared   && !$self->contacted;
	return SOLD      if  $self->scheduled   &&           1          &&  $self->started   &&  $self->sold   && !$self->cleared;# && !$self->contacted;
	return BIDDING   if  $self->scheduled   &&  $self->auctioneer   &&  $self->started   && !$self->sold;# && !$self->cleared;  && !$self->contacted;
	return ON_DECK   if  $self->scheduled   &&  $self->auctioneer   && !$self->started;# && !$self->sold   && !$self->cleared;  && !$self->contacted;
	return READY     if  $self->scheduled   && !$self->auctioneer;# && !$self->started   && !$self->sold   && !$self->cleared;  && !$self->contacted;
	return NOT_READY if !$self->scheduled;# && !$self->auctioneer   && !$self->started   && !$self->sold   && !$self->cleared;  && !$self->contacted;
	return UNKNOWN;
}

sub nstatus {
	my $self = shift;
	return 'Completed' if $self->status == COMPLETED;
	return 'Verifying' if $self->status == VERIFY;
	return 'Sold' if $self->status == SOLD;
	return 'Bidding' if $self->status == BIDDING;
	return 'On Deck' if $self->status == ON_DECK;
	return 'Ready' if $self->status == READY;
	return 'Not Ready' if $self->status == NOT_READY;
	return 'Unknown';
}

sub startbid {
	my $self = shift;
	my $startbid = eval { $self->schema->config->{database}->{options}->{starting_bid} } || [[100 * DOLLARS => 5 * DOLLARS], [250 * DOLLARS => 50 * DOLLARS], 100 * DOLLARS];
	foreach my $range ( sort { $a->[0] <=> $b->[0] } grep { ref eq 'ARRAY' } @$startbid ) {
		return $range->[1] if $self->value * DOLLARS < $range->[0] * DOLLARS;
	}
	return ((sort { $a <=> $b } grep { !ref } @$startbid)[0]) || 5 * DOLLARS;
}

sub minbid {
	my $self = shift;
	my $minbid_under = eval { $self->schema->config->{database}->{options}->{minimum_bid}->{under} } || 5 * DOLLARS;
	my $minbid_over = eval { $self->schema->config->{database}->{options}->{minimum_bid}->{under} } || 1 * DOLLARS;
	return undef unless $self->highbid;
	return $self->startbid unless $self->highbid->bid;
	return $self->highbid->bid+$minbid_under * DOLLARS if $self->highbid->bid * DOLLARS < $self->value * DOLLARS;
	return $self->highbid->bid+$minbid_over * DOLLARS;
}

sub cansell {
	my $self = shift;
	return 0 if $self->sold;
	return 0 unless $self->timer;
	my $mintimer = eval { $self->schema->config->{database}->{options}->{minimum_timer} } || 5 * MINUTES;
	my $datetime = eval { $self->schema->controller->datetime->epoch } || time;
	return $datetime - $self->timer->epoch > $mintimer ? TRUE : FALSE;
}

sub bellringer {
	my $self = shift;
	return undef unless $self->highbid;
	return undef unless $self->highbid->bid;
	return $self->highbid->bid >= $self->value ? TRUE : FALSE;
}

sub runningtime {
	my $self = shift;
	return undef unless $self->started;
	my $datetime = eval { $self->schema->controller->datetime->epoch } || time;
	return ($datetime - $self->started->epoch) * MINUTES;
}

sub timertime {
	my $self = shift;
	return undef unless $self->timer;
	my $datetime = eval { $self->schema->controller->datetime->epoch } || time;
	return ($datetime - $self->timer->epoch) * MINUTES;
}

#$r->notify;				returns list of set tags
#$r->notify([qw/newbid starttimer/]);	sets the tags to those specified
#$r->notify('newbid' => 1);		turns on (or off) the newbid tag  (Do NOT toggle)
#$r->notify('newbid');			returns t/f if this tag is set
sub notify {
        my $self = shift;
        return $self->notifications unless @_;
	my $notify = shift;
	if ( ref $notify eq 'ARRAY' ) {
		return $self->notifications(join ',', @$notify);
	} else {
		my $state = shift;
	        if ( $state ) {
        	        return $self->notifications(\"CONCAT_WS(',',notify,'$notify')");
	        } elsif ( defined $state ) {
        	        return $self->notifications(\"REPLACE(notify,'$notify','')");
	        } else {
			my @notify = split /,/, $self->notifications;
			return (grep { $_ eq $notify } @notify) ? $notify : undef;
		}
	}
}

sub respond { # ('newbid','starttimer','stoptimer','holdover','sell');
	my ($self, $notify) = @_;
	given ( $self->notify($notify) ) {
		when ( 'newbid' ) { return $self->notify('newbid'=>0) }
		when ( 'starttimer') { return $self->timer(\'now()')->notify('starttimer'=>0) }
		when ( 'stoptimer') { return $self->timer(undef)->notify('stoptimer'=>0) }
		when ( 'holdover' ) { return $self->notify('holdover'=>0) }
		when ( 'sell' ) { return $self->sold(\'now()')->notify('sell'=>0) }
	}
	return $self;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
