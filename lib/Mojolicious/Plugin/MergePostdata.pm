package Mojolicious::Plugin::MergePostdata;
use Mojo::Base 'Mojolicious::Plugin';

sub register {
	my ($self, $app, $conf) = @_;

	$app->hook(before_dispatch => sub {
		my $c = shift;
		my $content_type = $c->req->headers->content_type or return;
		my $ct;
		foreach ( grep { ref $conf->{$_} eq 'CODE' } keys %$conf ) {
			next unless $_ =~ /$content_type/ || $content_type =~ /$_/;
			$c->req->headers->content_type($_);
			$ct = $_ and last;
		}
		return unless $ct;
		my $cb = $conf->{$ct};
		return unless ref $cb eq 'CODE';
		my $postdata = $cb->($c);
		return unless ref $postdata eq 'HASH';
		$c->req->headers->add('X-MergePostData' => $ct);
		$c->param($_) or $c->param($_ => $postdata->{$_}) for keys %$postdata;
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
