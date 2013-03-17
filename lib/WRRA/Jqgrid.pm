package WRRA::Jqgrid;
use Mojo::Base 'Mojolicious::Controller';

sub create {
	my $self = shift;
	$self->render_exception('Invalid create request') unless $self->param('oper') eq 'add';
	$self->respond_to(
		json => {json => $self->jqgrid->create},
	);
}

sub read {
	my $self = shift;
	my $rs = $self->jqgrid->search;
	$self->respond_to(
		json => {json => $rs->paged},
		xls => sub {
			$self->render_xls(result => [map { $_->TO_XLS } $rs->all]);
		},
	);
}

sub update {
	my $self = shift;
	$self->render_exception('Invalid update request') unless $self->param('oper') eq 'edit';
	$self->respond_to(
		json => {json => $self->jqgrid->update},
	);
}

sub delete {
	my $self = shift;
	$self->render_exception('Invalid delete request') unless $self->param('oper') eq 'del';
	$self->respond_to(
		json => {json => $self->jqgrid->delete},
	);
}

1;
