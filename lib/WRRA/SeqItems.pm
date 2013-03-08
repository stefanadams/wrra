package WRRA::SeqItems;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::Exception;

sub read {
	my $self = shift;
warn Data::Dumper::Dumper($self->db->session);
	my $start = $self->db->session->{auctions}->{$self->db->session->{year}}->[0] or Mojo::Exception->throw('Cannot determine start date of auction '.$self->session->{year});
	my $n = $self->param('n');
	my $rs = $self->db->resultset($self->param('results'));
	my $scheduled;
	$scheduled = {'='=>undef} if not(defined $n) || $n <= 0 || $n =~ /\D/ || $start !~ /^\d{4}-\d{2}-\d{2}$/;
	$scheduled = {-or => [{'='=>undef},{'!='=>undef}]} if $n >= 9999;
	$n--;
	$scheduled ||= {'='=>\"date_add('$start', interval $n day)"};
	$rs->search($scheduled);
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
	my $start = $self->db->session->{auctions}->{$self->db->session->{year}}->[0] or Mojo::Exception->throw('Cannot determine start date of auction '.$self->session->{year});
	my $n = $self->param('n');
	my $rs = $self->db->resultset($self->param('results'));
	my $update;
	my @item_id = map { /_(\d+)$/; $1 } $self->merged->{id};
	my $r;
	if ( $n == 0 ) {
		$r = $rs->update({
			scheduled => undef,
			seq => \join('', 'FIND_IN_SET(item_id, "', join(',', @item_id), '")'),
		});
	} elsif ( $n > 0 and $n < 9999 ) {
		$n--;
		$r = $rs->update({
			scheduled => \"date_add('$start', interval $n day)",
			seq => \join('', 'FIND_IN_SET(item_id, "', join(',', @item_id), '")'),
		});
	}
	$self->respond_to(
		json => {json => {res=>($r?'ok':'err'),msg=>''}},
	);
}

1;
