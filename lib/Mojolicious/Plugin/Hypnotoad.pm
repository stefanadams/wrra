package Mojolicious::Plugin::Hypnotoad;
use Mojo::Base 'Mojolicious::Plugin';

use Mojo::Util qw(slurp);

sub register {
  my ($plugin, $app, $conf) = @_;

  $app->config(hypnotoad => {pid_file=>$app->home.'/.'.$app->moniker, listen=>[split ',', $ENV{MOJO_LISTEN}||'http://*:3000,https://*:3001'], proxy=>$ENV{MOJO_REVERSE_PROXY}||1});
}

1;

=head1 NAME

Mojolicious::Plugin::Hypnotoad - Hypnotoad defaults

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('Hypnotoad');

  # Mojolicious::Lite
  plugin 'Hypnotoad';

=head1 DESCRIPTION

L<Mojolicious::Plugin::Hypnotoad> adds hypnotoad defaults for L<Mojolicious>.

=head2 register

  $plugin->register(Mojolicious->new);

Register helpers in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
