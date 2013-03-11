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
	$self->render(rs => [$self->bs($self->db->resultset($self->param('results')))->all]);
}

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

sub ident {
	my $self = shift;
	$self->authenticate($self->param('username'), $self->param('phone'));
	warn 'Ident: ', $self->is_user_authenticated, "\n";
	$self->respond_to(
		json => {json => {username => $self->current_user->{username}}},
	);
}

sub unident {
	my $self = shift;
	delete $self->session->{username};
	$self->respond_to(
		json => {json => {username => $self->session->{username}}},
	);
}

sub header {
	my $self = shift;
	$self->respond_to(
		json => {json => $self->header_data},
	);
}

sub alert {
        my $self = shift;
	given ( $self->req->method ) {
		when ( 'DELETE' ) {
                        my $alert = $self->param('alert') || 'public';
                        my $msg = $self->param('msg');
                        my $r = $self->db->resultset('Alert')->search({alert=>$alert})->delete_all;
                        $self->respond_to(
                                json => {json => {clearalert => $r}},
                        );
		}
		when ('POST' ) {
                        my $alert = $self->param('alert') || 'public';
                        my $msg = $self->param('msg');
                        my $r = $self->db->resultset('Alert')->update_or_create({alert=>$alert, msg=>$msg}) if $alert && defined $msg;
                        $self->respond_to(
                                json => {json => {alert=>$r->alert, msg=>$r->msg}},
                        );
		}
		default {
		        my $alert = $self->param('alert') || 'public';
			my $rs = $self->db->resultset('Alert')->search({alert=>$alert})->first;
			$self->respond_to(
				json => {json => {msg => $rs?$rs->msg:undef}},
			);
		}
	}
}

sub ad {
        my $self = shift;
	my $ad = $self->db->resultset('Ads')->find($self->param('id')) or return $self->render_not_found;
	my $r;
	if ( $r = $self->db->resultset('Adcount')->find($self->param('id'), \'=cast(now() as date)') ) {
		$r->update({click=>$r->click+1});
	} elsif ( $r = $self->db->resultset('Adcount')->new({ad_id=>$self->param('id'), processed=>\'now()', click=>1}) ) {
		$r->insert;
	}
	warn $r->click;
	$self->redirect_to($ad->url||$self->config->{default_ad}->{url});
}

1;
