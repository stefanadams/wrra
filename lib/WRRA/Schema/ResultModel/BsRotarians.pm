package WRRA::Schema::ResultModel::BsRotarians;

use base 'WRRA::Schema::Result::Rotarian';

sub name {
	my $self = shift;
	join ', ', $self->lastname, $self->firstname;
}

sub TO_JSON { shift->hashref(qw(rotarian_id name)) }

1;
