package WRRA::Jqgrid;
use Mojo::Base 'Mojolicious::Controller';

sub create {
	my $self = shift;
	my $data = $self->db->resultset($self->param('source'))->view($self->param('view'))->jqgrid->create;
	$self->respond_to(
		json => {json => $data},
	);
}

sub read {
	my $self = shift;
	my $data = $self->db->resultset($self->param('source'))->view($self->param('view'))->jqgrid->search;
	$self->respond_to(
		json => {json => $data->all},
		xls => sub { # With TO_XLS
			$self->cookie(fileDownload => 'true');
			$self->cookie(path => '/');
			$self->render_xls(result => $data->all);
		},
	);
}

sub update {
	my $self = shift;
	my $data = $self->db->resultset($self->param('source'))->view($self->param('view'))->jqgrid->update;
	$self->respond_to(
		json => {json => $data},
	);
}

sub delete {
	my $self = shift;
	my $data = $self->db->resultset($self->param('source'))->view($self->param('view'))->jqgrid->delete;
	$self->respond_to(
		json => {json => $data},
	);
}

1;
