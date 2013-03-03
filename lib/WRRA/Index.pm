package WRRA::Index;
use Mojo::Base 'Mojolicious::Controller';

sub current_bidding {
	my $self = shift;
	$self->render_text('ok');
}

1;
