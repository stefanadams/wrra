package WRRA::Bidding;
use Mojo::Base 'Mojolicious::Controller';

sub read {
	my $self = shift;
	my $rs = $self->db->resultset($self->param('results'))->current_year->not_ready;
	$self->respond_to(
		json => {json => {bidding=>{rows=>[$rs->all]}}},
	);
}

1;
