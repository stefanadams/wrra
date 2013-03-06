package Mojolicious::Plugin::MergedParams;
use Mojo::Base 'Mojolicious::Plugin';

sub register {
	my ($self, $app, $conf) = @_;
	my $cb = $conf->{cb};

	$app->helper(merged => sub {
		my $c = shift;
		my $param = $c->req->params->to_hash;
		if ( ref $cb eq 'CODE' ) {
			my $postdata = $cb->($c->req->body);
			{%$param, %$postdata}
		} elsif ( $c->req->headers->content_type ) {
			given ( $c->req->headers->content_type ) {
				when ( 'application/json' ) {
					my $postdata = $c->req->json || {};
					return {%$param, %$postdata};
				}
				default {
					return {%$param};
				}
			}
		} else {
			{%$param}
		}
	});
}

1;

=head1 NAME

Mojolicious::Plugin::MergedParams - Access request as MergedParams

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('MergedParams');

  # Mojolicious::Lite
  plugin 'MergedParams';

=head1 DESCRIPTION

L<Mojolicious::Plugin::MergedParams> accesses request as MergedParams for L<Mojolicious>.

=head1 HELPERS

L<Mojolicious::Plugin::MergedParams> implements the following helpers.

=head2 json

  %= json 'foo'

=head1 METHODS

L<Mojolicious::Plugin::MergedParams> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register helpers in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
