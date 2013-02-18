package WRRA::Controller::Api;
use Mojo::Base 'WRRA::Controller::Base';

use Data::Dumper;

sub auto_complete {
	my $self = shift;
	$self->view($self->param('mv')) or $self->render_exception;
	my $m = $self->model($self->param('mv')) or $self->render_exception;
	$self->respond_to(
		json => sub {
			$self->render_json($m->read->json);
		},
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
