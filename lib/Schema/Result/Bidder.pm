package Schema::Result::Bidder;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Schema::Result';

__PACKAGE__->load_components("InflateColumn::DateTime", "Helper::Row::ToJSON");

=head1 NAME

Schema::Result::Bidder

=cut

__PACKAGE__->table("bidders");

=head1 ACCESSORS

=head2 bidder_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 year

  data_type: 'year'
  is_nullable: 1

=head2 username_r

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 username

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 phone

  data_type: 'varchar'
  is_nullable: 0
  size: 15

=head2 name_r

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 address

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 city

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 state

  data_type: 'char'
  is_nullable: 1
  size: 2

=head2 zip

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 email

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "bidder_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "year",
  { data_type => "year", is_nullable => 1 },
  "username_r",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "username",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "phone",
  { data_type => "varchar", is_nullable => 0, size => 15 },
  "name_r",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "address",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "city",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "state",
  { data_type => "char", is_nullable => 1, size => 2 },
  "zip",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("bidder_id");
__PACKAGE__->add_unique_constraint("year_phone", ["year", "phone"]);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-11-17 16:47:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2t8acyejbEASJya1gtfVnA

use Class::Method::Modifiers;
__PACKAGE__->has_many(bids => 'Schema::Result::Bid', 'bidder_id'); # A Bidder has_many Bids, join to Bid by bidder_id
__PACKAGE__->many_to_many(items => 'bids', 'item'); # A Bidder bids on many Items, bridge to item via Bid's bids

use overload '""' => sub { shift->name }, fallback => 1;

around 'phone' => sub {
	my $orig = shift;
	my $self = shift;
	if ( $_[0] ) {
		$_[0] =~ s/\D//g;
		$_[0] = "($1) $2-$3" if $_[0] =~ /^(\d{3})(\d{3})(\d{4})$/;
	}
	return $self->$orig(@_);
};

sub TO_JSON {
	my $self = shift;

	return {
		%{$self->next::method},
#		Also available, but instead access it via Bidder sub-classes
#		  bids => [$self->bids],
#		  items => [$self->items],
	}
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
