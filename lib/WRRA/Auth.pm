package WRRA::Auth;
use Mojo::Base 'Mojolicious::Controller';

sub register {
	my $self = shift;
	return $self->render_json({res=>'err',msg=>'Missing username'}) unless $self->param('username');
	return $self->render_json({res=>'err',msg=>'Missing name'}) unless $self->param('name');
	return $self->render_json({res=>'err',msg=>'Missing phone'}) unless $self->param('phone');
	my $r = $self->db->resultset('Bidder')->create({username_r=>$self->param('username'),name=>$self->param('name'),phone=>$self->param('phone')});
	$self->respond_to(
		json => {json => {res => 'ok'}},
	);
}

sub Login {
	my $self = shift;
	$self->authenticate($self->param('username'), $self->param('phone'));
	$self->respond_to(
		json => {json => {user => {name => $self->current_user?$self->current_user->{username}:Mojo::JSON->false, role=>$self->role||Mojo::JSON->false}}},
	);
}

sub Logout {
	my $self = shift;
	$self->logout;
	$self->respond_to(
		json => {json => {user => {name => $self->current_user?$self->current_user->{username}:Mojo::JSON->false, role=>$self->role||Mojo::JSON->false}}},
	);
}

1;
