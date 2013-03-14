package WRRA::Ad;
use Mojo::Base 'Mojolicious::Controller';

sub ad {
        my $self = shift;
	my $ad = $self->db->resultset('Ads')->find($self->param('id')) or return $self->render_not_found;
	my $r;
	if ( $r = $self->db->resultset('Adcount')->find($self->param('id'), \'=cast(now() as date)') ) {
		$r->update({click=>$r->click+1});
	} elsif ( $r = $self->db->resultset('Adcount')->new({ad_id=>$self->param('id'), processed=>\'now()', click=>1}) ) {
		$r->insert;
	}
	$self->redirect_to($ad->url||$self->config->{default_ad}->{url});
}

1;
