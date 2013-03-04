package DBIx::Class::Helper::Schema::Mojolicious;
{
  $DBIx::Class::Helper::Schema::Mojolicious::VERSION = '0.1.0';
}

use strict;
use warnings;

use 5.010;

sub controller {
	my ($self, $c) = (shift, shift);
	if ( $c ) {
		$self->{_controller} = $c;
		my $rs_class = ref($self).'::ResultSet';
		$rs_class->load_components(qw(Helper::ResultSet::Mojolicious));
	}
	$self->{_controller};
}
 
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
#warn Data::Dumper::Dumper([@_]);
	$_ = {%{$self->config(@_)}, %{$c->session(@_)}};
#warn Data::Dumper::Dumper($_);
	return $_;
#	return {%{$self->config(@_)}, %{$c->session(@_)}};
}

sub stash {
	my $self = shift;
	my $c = $self->controller or return undef;
	return undef unless $c->can('stash');
	return {map { $_ => $c->stash->{$_} } grep { !/^mojo\./ } keys %{$c->stash}};
}

sub param {
	my $self = shift;
	my $c = $self->controller or return undef;
	return undef unless $c->can('param');
	return $c->req->params->to_hash;
}

sub postdata {
	my $self = shift;
	my $c = $self->controller or return undef;
	return undef unless $c->can('stash');
	my $postdata;
	if ( $c->req->headers->content_type ) {
		given ( $c->req->headers->content_type ) {
			when ( 'application/json' ) { $postdata = $c->req->json }
		}
	}
	return $postdata || {};
}

sub request {
	my $self = shift;
	return {%{$self->postdata}, %{$self->param}};
}

1;
