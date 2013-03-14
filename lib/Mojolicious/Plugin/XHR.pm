package Mojolicious::Plugin::XHR;
use Mojo::Base 'Mojolicious::Plugin';

sub register {
	my ($self, $app, $conf) = @_;

	# $r->over(xhr=>1);
	$app->routes->add_condition(xhr => sub {
		my ($r, $c, $captures, $patterns) = @_;
		return $c->req->is_xhr == $patterns;
	});
	# $r->xhr;
	$app->routes->add_shortcut(xhr => sub {
		my ($r, $want) = @_;
		return $r->over(xhr=>$want//1);
	});
}

1;
