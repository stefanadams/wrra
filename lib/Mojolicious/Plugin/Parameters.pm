package Mojolicious::Plugin::Parameters;
use Mojo::Base 'Mojolicious::Plugin';

use Data::Dumper ();
use Mojo::ByteStream;

sub register {
  my ($self, $app) = @_;

  $app->helper(parameters => sub {
        my $self = shift;
        unless ( $self->{__PARAMETERS} ) {
                $self->{__PARAMETERS} = {map { $_ => $self->param($_) } $self->param};
                #warn Dumper($self->{__PARAMETERS});
        }
        return $self->{__PARAMETERS}||{};
  });
}

1;

=head1 NAME

Mojolicious::Plugin::JSON - Access request as JSON

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('JSON');

  # Mojolicious::Lite
  plugin 'JSON';

=head1 DESCRIPTION

L<Mojolicious::Plugin::JSON> accesses request as JSON for L<Mojolicious>.

=head1 HELPERS

L<Mojolicious::Plugin::JSON> implements the following helpers.

=head2 json

  %= json 'foo'

=head1 METHODS

L<Mojolicious::Plugin::JSON> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register helpers in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
