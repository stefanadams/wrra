package Schema::Result::Donor;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Schema::Result';

__PACKAGE__->load_components("InflateColumn::DateTime", "Helper::Row::ToJSON");

=head1 NAME

Schema::Result::Donor

=cut

__PACKAGE__->table("donors");

=head1 ACCESSORS

=head2 donor_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 chamberid

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 phone

  data_type: 'varchar'
  is_nullable: 0
  size: 15

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 category

  data_type: 'set'
  extra: {list => ["bank","lawyer","realty","doctor","cpa","personal","esq","seq","insurance"]}
  is_nullable: 1

=head2 contact1

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 contact2

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 address

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 city

  data_type: 'varchar'
  is_nullable: 0
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

=head2 url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 advertisement

  data_type: 'varchar'
  is_nullable: 1
  size: 1200

=head2 solicit

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

=head2 comments

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 rotarian_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "donor_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "chamberid",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "phone",
  { data_type => "varchar", is_nullable => 0, size => 15 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "category",
  {
    data_type => "set",
    extra => {
      list => [
        "bank",
        "lawyer",
        "realty",
        "doctor",
        "cpa",
        "personal",
        "esq",
        "seq",
        "insurance",
      ],
    },
    is_nullable => 1,
  },
  "contact1",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "contact2",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "address",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "city",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "state",
  { data_type => "char", is_nullable => 1, size => 2 },
  "zip",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "advertisement",
  { data_type => "varchar", is_nullable => 1, size => 1200 },
  "solicit",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "comments",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "rotarian_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("donor_id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-11-17 16:47:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mlHqXeu6uTlU0UdnJ2j4Tg

__PACKAGE__->belongs_to(rotarian => 'Schema::Result::Rotarian', 'rotarian_id');	# A Donor belongs_to a Rotarian
__PACKAGE__->has_many(items => 'Schema::Result::Item', 'donor_id'); # A Donor has_many Items

use overload '""' => sub {shift->name}, fallback => 1;

sub contact {
	my $self = shift;
	return join('|', grep { $_ } $self->contact1, $self->contact2) || undef;
}

sub TO_JSON {
	my $self = shift;

	return {
		contact => $self->contact,
		rotarian => $self->rotarian->name,
		ly_items => $self->items->count,
		%{$self->next::method},
#		Also available, but instead access it via Bid sub-classes   
#		  rotarian => $self->rotarian,
#		  recent_items => [$self->items->recent_years->all],
	}
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
