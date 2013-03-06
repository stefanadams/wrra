package Mojolicious::Plugin::Version;
use Mojo::Base 'Mojolicious::Plugin';

use Mojo::Util qw(slurp);

sub register {
  my ($plugin, $app, $conf) = @_;

  $app->config(version => -e $app->home.'/version' ? slurp $app->home.'/version' : undef);
}

1;

=head1 NAME

Mojolicious::Plugin::Version - Import app Version

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('Version');

  # Mojolicious::Lite
  plugin 'Version';

=head1 DESCRIPTION

L<Mojolicious::Plugin::Version> adds version to L<Mojolicious> app.

=head2 register

  $plugin->register(Mojolicious->new);

Register helpers in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
