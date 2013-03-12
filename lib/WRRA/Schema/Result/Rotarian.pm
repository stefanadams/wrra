package WRRA::Schema::Result::Rotarian;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'WRRA::Schema::Result';

=head1 NAME

WRRA::Schema::Result::Rotarian

=cut

__PACKAGE__->table("rotarians");

=head1 ACCESSORS

=head2 rotarian_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 lead

  data_type: 'tinyint'
  is_nullable: 1

=head2 lastname

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 firstname

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 has_submissions

  accessor: '_has_submissions'
  data_type: 'tinyint'
  is_nullable: 1

=head2 leader_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 phone

  data_type: 'varchar'
  is_nullable: 1
  size: 15

=head2 email

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "rotarian_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "lead",
  { data_type => "tinyint", is_nullable => 1 },
  "lastname",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "firstname",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "has_submissions",
  {
    data_type   => "tinyint",
    is_nullable => 1,
  },
  "leader_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "phone",
  { data_type => "varchar", is_nullable => 1, size => 15 },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("rotarian_id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-11-17 16:47:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1zU/03XgJD476ZgsRgaw0g

use Class::Method::Modifiers;
__PACKAGE__->has_many(donors => 'WRRA::Schema::Result::Donor', 'rotarian_id'); # A Rotarian has_many Donors that s/he solicits
__PACKAGE__->belongs_to(leader => 'WRRA::Schema::Result::Leader', {'foreign.leader_id'=>'self.rotarian_id'});

sub id { shift->rotarian_id }

around 'phone' => sub {
	my $orig = shift;
	my $self = shift;
	if ( $_[0] ) {
		$_[0] =~ s/\D//g;
		$_[0] = "($1) $2-$3" if $_[0] =~ /^(\d{3})(\d{3})(\d{4})$/;
	}
	return $self->$orig(@_);
};

around 'has_submissions' => sub {
	my $orig = shift;
	my $self = shift;
	return 1 if $self->$orig;
	$_[0] = $self->$orig ? 1 : $self->search_related('donors')->search_related('items')->current_year('items')->count ? 1 : 0;
	return $self->$orig(@_);
};

sub name {
	my $self = shift;
	if ( $self->lastname && $self->firstname ) {
		return join ', ', $self->lastname, $self->firstname;
	} else {
		return join('', grep { $_ } $self->lastname, $self->firstname) || undef;
	}
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
