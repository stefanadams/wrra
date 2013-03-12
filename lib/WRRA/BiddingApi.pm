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

sub notify : Runmode RequireAjax Authen Authz('admins') {
        my $self = shift;
        $self->dbh->do("UPDATE items_vw SET notify = CONCAT_WS(',',notify,?) WHERE item_id=?", undef, $self->param('notify'), $self->param('item'));
        return $self->to_json({error=>0});
}

sub respond : Runmode RequireAjax Authen Authz('auctioneers') {
        my $self = shift;
        if ( $self->param('respond') eq 'start' ) {
                $self->dbh->do("UPDATE items_vw SET started=now() WHERE item_id=?", undef, $self->param('item'));
        } elsif ( $self->param('respond') eq 'newbid' ) {
                $self->dbh->do("UPDATE items_vw SET notify=REPLACE(notify,'newbid','') WHERE item_id=?", undef, $self->param('item'));
        } elsif ( $self->param('respond') eq 'starttimer' ) {
                $self->dbh->do("UPDATE items_vw SET timer=now(),notify=REPLACE(notify,'starttimer','') WHERE item_id=?", undef, $self->param('item'));
        } elsif ( $self->param('respond') eq 'stoptimer' ) {
                $self->dbh->do("UPDATE items_vw SET timer=null,notify=REPLACE(notify,'stoptimer,'') WHERE item_id=?", undef, $self->param('item'));
        } elsif ( $self->param('respond') eq 'holdover' ) {
                $self->dbh->do("UPDATE items_vw SET notify=REPLACE(notify,'holdover','') WHERE item_id=?", undef, $self->param('item'));
        } elsif ( $self->param('respond') eq 'sell' ) {
                my $item = $self->dbh->selectrow_hashref("SELECT sold FROM items WHERE id=?", undef, $self->param('item'));
                $self->dbh->do("UPDATE items_vw SET ".(!$item->{sold}?'sold':'cleared')."=now(),notify=REPLACE(notify,'sell','') WHERE item_id=?", undef, $self->param('item'));
        }
        return $self->to_json({error=>0});
}
sub notify {
	my $self = shift;
	my ($notify, $id, $state) = ($self->param('notify'), $self->param('id'), $self->param('state'));
	my $r = $self->db->resultset('Item')->find($id)->notify($notify, $state)->update;
	$self->respond_to(
		json => {json => {res=>$r?'ok':'err'}},
	);
}

sub sell {
	my $self = shift;
	my ($id) = ($self->param('id'));
	my $r = $self->db->resultset('Item')->find($id)->sold(\'now()')->update;
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
