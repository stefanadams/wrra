package Mojolicious::Plugin::MyConfig;
use Mojo::Base 'Mojolicious::Plugin';

use Mojo::Util qw(slurp);
use File::Basename;
use FindBin qw($Bin);
use lib "$Bin/lib";

sub register {
  my ($plugin, $app, $conf) = @_;

  my $basename = basename $0, '.pl';

  $app->config(version => -e "$Bin/version" ? slurp "$Bin/version" : -e "$Bin/../version" ? slurp "$Bin/../version" : undef);
  $app->config(hypnotoad => {pid_file=>"$Bin/../.$basename", listen=>[split ',', $ENV{MOJO_LISTEN}||'https://*'], proxy=>$ENV{MOJO_REVERSE_PROXY}||1});
}

1;

=head1 NAME

Mojolicious::Plugin::MyConfig - Hypnotoad and Version defaults

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('MyConfig');

  # Mojolicious::Lite
  plugin 'MyConfig';

=head1 DESCRIPTION

L<Mojolicious::Plugin::MyConfig> adds version and hypnotoad defaults for L<Mojolicious>.

=head2 register

  $plugin->register(Mojolicious->new);

Register helpers in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
