package Mojolicious::Plugin::MyProcess;
use Mojo::Base 'Mojolicious::Plugin';

use Mojo::JSON;

sub register {
	my ($self, $app, $conf) = @_;
	my $cb = $conf->{cb};

	$app->helper(mysession => sub {
		my $c = shift;
		return $c->session
	});
	$app->helper(myconfig => sub {
		my $c = shift;
		return $c->config
	});
	$app->helper(myparam => sub {
		my $c = shift;
		return {map { $_ => $c->req->param($_) } $c->req->param};
	});
	$app->helper(mypostdata => sub {
		my $c = shift;
		return $c->req->body
	});
	$app->helper(mystash => sub {
		my $c = shift;
		return {map { $_ => $c->stash->{$_} } grep { !/^mojo\./ } keys %{$c->stash}}
	});
	$app->helper(myrequest => sub {
		my $c = shift;
		my $param = $c->myparam;
		if ( ref $cb eq 'CODE' ) {
			my $postdata = $cb->($c->mypostdata);
			{%$param, %$postdata}
		} elsif ( $c->req->headers->content_type ) {
			if ( grep { $c->req->headers->content_type eq $_ } qw(application/json) ) {
				#my $postdata = $c->mypostdata ? Mojo::JSON->new->decode($c->mypostdata) : {};
				my $postdata = $c->req->json || {};
				{%$param, %$postdata}
			}
		} else {
			{%$param}
		}
	});
}

1;

=head1 NAME

Mojolicious::Plugin::MyStash - Access request as MyStash

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('MyStash');

  # Mojolicious::Lite
  plugin 'MyStash';

=head1 DESCRIPTION

L<Mojolicious::Plugin::MyStash> accesses request as MyStash for L<Mojolicious>.

=head1 HELPERS

L<Mojolicious::Plugin::MyStash> implements the following helpers.

=head2 json

  %= json 'foo'

=head1 METHODS

L<Mojolicious::Plugin::MyStash> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register helpers in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
