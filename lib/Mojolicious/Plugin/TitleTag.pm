package Mojolicious::Plugin::TitleTag;

use Mojo::Base 'Mojolicious::Plugin';

our $VERSION = 0.01;

sub register {
  my ($plugin, $app, $conf) = @_;

  $app->hook(
    after_dispatch => sub {
      my $c = shift;
      $conf->{tag} or return;

      return unless $c->app->mode eq 'development';

      my $body = $c->res->body;
      my $tag = ref $conf->{tag} eq 'CODE' ? $conf->{tag}->($c) : ref $conf->{tag} ? '' : $conf->{tag};
      return unless $body =~ s/<\s*\/\s*title>/ - $tag<\/title>/i;
      $c->res->body($body);
    }
  );
}

1;
