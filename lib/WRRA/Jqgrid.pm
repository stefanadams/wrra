package WRRA::Jqgrid;
use Mojo::Base 'Mojolicious::Controller';

sub create {
	my $self = shift;
	$self->view($self->param('v')) or $self->render_exception;
	my $m = $self->model($self->param('m')) or $self->render_exception;
	$self->respond_to(
		json => sub {
			$self->render_json($m->create);
		},
	);
}

sub read {
	my $self = shift;
	my $data = $self->db->resultset($self->param('source'))->myrequest($self->myrequest)->view($self->param('view'))->jqgrid->search;
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
	$self->view($self->param('v')) or $self->render_exception;
	my $m = $self->model($self->param('m')) or $self->render_exception;
	$self->respond_to(
		json => sub {
			$self->render_json($m->update);
		},
	);
}

sub delete {
	my $self = shift;
	$self->view($self->param('v')) or $self->render_exception;
	my $m = $self->model($self->param('m')) or $self->render_exception;
	$self->respond_to(
		json => sub {
			$self->render_json($m->delete);
		},
	);
}

1;
