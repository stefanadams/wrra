package DBIx::Class::Helper::Schema::Mojolicious;
{
  $DBIx::Class::Helper::Schema::Mojolicious::VERSION = '0.1.0';
}

sub controller { shift->storage->_connect_info->[0]->{controller} }
 
sub config {
	my $self = shift;
	no strict;
	my $defaults = ${(ref $self)."::defaults"};
	ref $defaults eq 'HASH' or $defaults = {};
	my $c = $self->controller or return $defaults;
	return $defaults unless $c->can('config');
	return {%$defaults, %{$c->config(@_)}};
}
 
sub session {
	my $self = shift;
	my $c = $self->controller or return $self->config(@_);
	return $self->config(@_) unless $c->can('session');
	return {%{$self->config(@_)}, %{$c->session(@_)}};
}

1;
