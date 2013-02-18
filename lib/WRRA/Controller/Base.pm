package WRRA::Controller::Base;
use Mojo::Base 'WRRA::Controller';

use WRRA::View;

use Data::Dumper;

sub view {
	my $self = shift;
	my $view = shift or return undef;
	WRRA::View->set($view);
	WRRA::View->request(map %{$self->$_}, qw(session json parameters));
	return $view;
}

1;
