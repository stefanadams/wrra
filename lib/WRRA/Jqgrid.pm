package WRRA::Jqgrid;
use Mojo::Base 'Mojolicious::Controller';

sub create {
	my $self = shift;
	$self->render_exception('Invalid create request') unless delete $self->request->{oper} eq 'add';
	my $r = $self->jqgrid->create;
	$self->respond_to(
		json => {json => {res=>($r?'ok':'err'),msg=>'',number=>$r->number}},
	);
}

sub read {
	my $self = shift;
	my $rs = $self->jqgrid->search;
	$self->respond_to(
		json => {json => $rs->paged},
		xls => sub { # With TO_XLS
			$self->cookie(fileDownload => 'true');
			$self->cookie(path => '/');
			$self->render_xls(result => $rs->all);
		},
	);
}

sub update {
	my $self = shift;
	$self->render_exception('Invalid update request') unless delete $self->request->{oper} eq 'edit';
	my $r = $self->jqgrid->update;
	$self->respond_to(
		json => {json => {res=>($r?'ok':'err'),msg=>''}},
	);
}

sub delete {
	my $self = shift;
	$self->render_exception('Invalid delete request') unless delete $self->request->{oper} eq 'del';
	my $r = $self->jqgrid->delete;
	$self->respond_to(
		json => {json => {res=>($r?'ok':'err'),msg=>''}},
	);
}

1;
