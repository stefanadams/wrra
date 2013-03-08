package Mojolicious::Plugin::XHR;
use Mojo::Base 'Mojolicious::Plugin';

sub register {
	my ($self, $app, $conf) = @_;

	$app->routes->add_shortcut(xhr => sub { shift->over(is_xhr=>shift||1) });
	$app->routes->add_condition(xhr => sub { $_[1]->req->is_xhr == $_[3] });
}

1;
