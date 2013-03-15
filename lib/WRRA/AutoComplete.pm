package WRRA::AutoComplete;
use Mojo::Base 'Mojolicious::Controller';

sub auto_complete {
	my $self = shift;
	my $rs = $self->ac($self->db->resultset($self->param('results')));
	$self->respond_to(
		json => {json => [$rs->all]},
	);
}

1;
