package WRRA::BiddingApi;
use Mojo::Base 'Mojolicious::Controller';

sub assign {
	my $self = shift;
	my ($id, $auctioneer) = ($self->param('id'), $self->param('auctioneer'));
	my $r = $self->db->resultset('Item')->find($id)->update({auctioneer=>$auctioneer});
	$self->respond_to(
		json => {json => {res=>$r?'ok':'err'}},
	);
}

sub notify {
	my $self = shift;
	my ($notify, $id, $state) = ($self->param('notify'), $self->param('id'), $self->param('state'));
	my $r = $self->db->resultset('Item')->find($id)->update({auctioneer=>$auctioneer});
	$self->respond_to(
		json => {json => {res=>$r?'ok':'err'}},
	);
}

sub sell {
	my $self = shift;
	my ($id) = ($self->param('id'));
	my $r = $self->db->resultset('Item')->find($id)->update({sold=>\'now()'});
	$self->respond_to(
		json => {json => {res=>$r?'ok':'err'}},
	);
}

sub timer {
	my $self = shift;
	my ($id, $state) = ($self->param('id'), $self->param('state'));
	my $r = $self->db->resultset('Item')->find($id)->update({sold=>\'now()'});
	$self->respond_to(
		json => {json => {res=>$r?'ok':'err'}},
	);
}

sub bid {
	my $self = shift;
	my ($id, $bidder, $bid) = ($self->param('id'), $self->param('bidder_id'), $self->param('bid'));
	my $r = $self->db->resultset('Item')->find($id)->update({sold=>\'now()'});
	$self->respond_to(
		json => {json => {res=>$r?'ok':'err'}},
	);
}

1;
