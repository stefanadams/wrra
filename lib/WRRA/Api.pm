package WRRA::Api;
use Mojo::Base 'Mojolicious::Controller';

sub api_dbconfig {
	my $self = shift;
	$self->session->{$self->param('config')} = $self->param($self->param('config')) if $self->param($self->param('config'));
	$self->respond_to(
		json => {json => {$self->param('config') => $self->db->session->{$self->param('config')}}},
	);
}

sub auto_complete {
	my $self = shift;
	my $rs = $self->ac($self->db->resultset($self->param('results')));
	$self->respond_to(
		json => {json => [$rs->all]},
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
