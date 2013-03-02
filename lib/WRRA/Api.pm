package WRRA::Api;
use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

sub auto_complete {
	my $self = shift;
	my $data = $self->db->resultset($self->param('source'))->view($self->param('view'))->myrequest($self->myrequest);
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

1;
