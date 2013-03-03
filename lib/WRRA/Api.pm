package WRRA::Api;
use Mojo::Base 'Mojolicious::Controller';

sub auto_complete {
	my $self = shift;
	my $data = $self->db->resultset($self->param('source'))->set_myrequest($self->myrequest)->view($self->param('view'));
	$self->respond_to(
		json => {json => [$data->all]},
	);
}

sub build_select {
	my $self = shift;
	$self->view($self->param('mv')) or $self->render_exception;
	my $m = $self->model($self->param('mv')) or $self->render_exception;
	$self->stash(select => [$m->read->all]);
}

sub item_number {
	my $self = shift;
	$self->view($self->param('mv')) or $self->render_exception;
	my $m = $self->model($self->param('mv')) or $self->render_exception;
	$self->render_text($m->read->first->number);
}

sub api_year {
	my $self = shift;
	$self->respond_to(
		json => {json => $self->year},
	);
}

sub api_session {
	my $self = shift;
	$self->session->{$_} = $self->param($_) for $self->param;
	$self->respond_to(
		json => {json => $self->session},
	);
}

1;
