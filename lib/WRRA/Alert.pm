package WRRA::Alert;
use Mojo::Base 'Mojolicious::Controller';

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

1;
