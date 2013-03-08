package Mojolicious::Plugin::LogRequests;
use Mojo::Base 'Mojolicious::Plugin';

use Mojo::Util qw(slurp);
use File::Basename;
use FindBin qw($Bin);
use lib "$Bin/lib";

sub register {
  my ($plugin, $app, $conf) = @_;

    $app->hook(after_dispatch => sub {
            my $c = shift;
            # As "defaults" values are not deep-copied, setting a hashref there
            # would just copy that hashref and stash modifications would actually
            # modify the defaults.
            $c->stash(info  => []);  
            $c->stash(error => []);
 
            # Debug request logging
	    my $tag    = ref $conf->{tag} eq 'CODE' ? $conf->{tag}->($c) : ref $conf->{tag} ? '' : $conf->{tag} || '[tag]';
            my $req    = $c->req;
            my $method = $req->method;  
            my $path   = $req->url->path->to_abs_string;
            my $params = $req->params->to_string;
            my $xhr    = $c->req->is_xhr ? '(XHR)' : '';
            my $headers= $req->headers->to_string;
            my $body   = $req->body;
            return if $path =~ /\.js$|\.css$/;
            print STDERR "REQ : $tag : $method$xhr $path [$params]\n";
            print STDERR "HEADERS: $headers\n" if $ENV{MOJO_HEADERS};
            print STDERR "BODY: $body\n" if $xhr;
        });
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
