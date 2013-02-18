package WRRA::Schema::Result;

use base 'DBIx::Class::Core';
__PACKAGE__->load_components(qw/InflateColumn::DateTime Helper::Row::ToJSON/);

sub resolver { () }

sub eval { my $self = shift; my $eval = eval($_[0]); return $@ ? '' : $eval }
sub nameid { my $self = shift; join ':', $self->name, $self->id; }
sub _value { shift->value }

sub arrayref {
	my $self = shift;

	return [map { local @_ = eval { scalar $self->$_ }; $@ ? undef : (@_) } @_];
}
 
sub hashref {
	my $self = shift;

	return {map { local %_ = eval { $_ => scalar $self->$_ }; $@ ? () : (%_) } @_};
}

1;
