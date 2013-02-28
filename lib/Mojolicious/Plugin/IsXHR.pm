package Mojolicious::Plugin::IsXHR;
use Mojo::Base 'Mojolicious::Plugin';

sub register { $_[1]->routes->add_condition(is_xhr => sub { $_[1]->req->is_xhr == $_[3] }) }

1;
