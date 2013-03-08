package WRRA::Crud;
use Mojo::Base 'Mojolicious::Controller';

sub create {
	my $self = shift;
	my $r = $self->crud(create => $self->db->resultset($self->param('results')));
	$self->respond_to(
		json => {json => {res=>($r?'ok':'err'),msg=>'',number=>$r->number}},
	);
}

sub read {
	my $self = shift;
	my $rs = $self->crud(search => $self->db->resultset($self->param('results')));
	$self->respond_to(
		json => {json => [$rs->all]},
		xls => sub { # With TO_XLS
			$self->cookie(fileDownload => 'true');
			$self->cookie(path => '/');
			$self->render_xls(result => $rs->all);
		},
	);
}

sub update {
	my $self = shift;
	my $r = $self->crud(update => $self->db->resultset($self->param('results')));
	$self->respond_to(
		json => {json => {res=>($r?'ok':'err'),msg=>''}},
	);
}

sub delete {
	my $self = shift;
	my $r = $self->crud(delete => $self->db->resultset($self->param('results')));
	$self->respond_to(
		json => {json => {res=>($r?'ok':'err'),msg=>''}},
	);
}

1;
