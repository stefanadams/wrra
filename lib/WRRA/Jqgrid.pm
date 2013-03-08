package WRRA::Jqgrid;
use Mojo::Base 'Mojolicious::Controller';

sub create {
	my $self = shift;
	$self->render_exception('Invalid create request') unless delete $self->merged->{oper} eq 'add';
	$self->respond_to(
		json => {json => $self->jqgrid->create},
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
	$self->render_exception('Invalid update request') unless delete $self->merged->{oper} eq 'edit';
	$self->respond_to(
		json => {json => $self->jqgrid->update},
	);
}

sub delete {
	my $self = shift;
	$self->render_exception('Invalid delete request') unless delete $self->merged->{oper} eq 'del';
	$self->respond_to(
		json => {json => $self->jqgrid->delete},
	);
}

1;
