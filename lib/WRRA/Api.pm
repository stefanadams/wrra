package WRRA::Api;
use Mojo::Base 'Mojolicious::Controller';

use 5.010;

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

sub header {
	my $self = shift;
	$self->respond_to(
		json => {json => {
			header => {
				about => {
					name => 'Washington Rotary Radio Auction',
					year => $self->db->session->{year},
					night => $self->db->session->{auctions}->{$self->db->session->{year}}->[0],
					live => 0,
					date_next => 'Tomorrow',
				},
				play => $self->config('play'),
			},
		}},
	);
}

sub alert {
        my $self = shift;
	given ( $self->req->method ) {
		when ( 'DELETE' ) {
                        #my $alert = $self->session->id;
                        #$self->dbh->do('DELETE FROM alerts WHERE alert=? LIMIT 1', undef, $alert) or return $self->to_json({clearalert=>undef});
                        #return $self->to_json({clearalert=>1})
                        $self->respond_to(
                                json => {json => {clearalert => 1}},
                        );
		}
		when ('POST' ) {
warn $self->param('alert');
                        my $alert = $self->merged->{alert} || 'public';
                        my $msg = $self->merged->{msg};
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

1;
