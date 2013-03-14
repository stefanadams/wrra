package WRRA::BuildSelect;
use Mojo::Base 'Mojolicious::Controller';

sub build_select {
	my $self = shift;
	$self->render(rs => [$self->bs($self->db->resultset($self->param('results')))->all]);
}

1;
