package WRRA::Jqgrid;
use Mojo::Base 'Mojolicious::Controller';

sub create {
	my $self = shift;
	my $r = $self->jqgrid(create => $self->db->resultset($self->param('results')));
	$self->respond_to(
		json => {json => {res=>($r?'ok':'err'),msg=>'',number=>$r->number}},
	);
}

sub read {
	my $self = shift;
	my $rs = $self->jqgrid(search => $self->db->resultset($self->param('results')));
	$self->respond_to(
		json => {json => $rs->jqgrid},
		xls => sub { # With TO_XLS
			$self->cookie(fileDownload => 'true');
			$self->cookie(path => '/');
			$self->render_xls(result => $rs->all);
		},
	);
}

sub update {
	my $self = shift;
	my $r = $self->jqgrid(update => $self->db->resultset($self->param('results')));
	$self->respond_to(
		json => {json => {res=>($r?'ok':'err'),msg=>''}},
	);
}

sub delete {
	my $self = shift;
	my $r = $self->jqgrid(delete => $self->db->resultset($self->param('results')));
	$self->respond_to(
		json => {json => {res=>($r?'ok':'err'),msg=>''}},
	);
}

1;
