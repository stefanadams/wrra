package WRRA::Schema::Result::Leader;

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
  "lastname",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "firstname",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "phone",
  { data_type => "varchar", is_nullable => 1, size => 15 },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("rotarian_id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-11-17 16:47:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1zU/03XgJD476ZgsRgaw0g

__PACKAGE__->has_many(rotarians => 'WRRA::Schema::Result::Rotarian', {'foreign.leader_id'=>'self.rotarian_id'});

use overload '""' => sub {shift->name}, fallback => 1;

sub name {
	my $self = shift;
	if ( $self->lastname && $self->firstname ) {
		return join ', ', $self->lastname, $self->firstname;
	} else {
		return join('', grep { $_ } $self->lastname, $self->firstname) || undef;
	}
}

sub TO_JSON {
	my $self = shift;

	return {
		name => $self->name,
		%{$self->next::method},
		# Override inflated accessors: Are we CERTAIN that these will ALWAYS override those set in next::method?
#		Also available, but instead access it via Rotarian sub-classes
#		  rotarians => [$self->rotarians],
	}
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
