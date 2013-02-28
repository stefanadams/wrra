package Mojolicious::Plugin::TitleVersion;

use Mojo::Base 'Mojolicious::Plugin';

our $VERSION = 0.01;

sub register {
  my ($plugin, $app) = @_;

  $app->hook(
    after_dispatch => sub {
      my $self = shift;

      return unless $self->app->mode eq 'development';

      my $body = $self->res->body;
      my $version = $self->config('version');
      return unless $body =~ s/<\s*\/\s*title>/ - $version<\/title>/i;
      $self->res->body($body);
    }
  );
}

1;
