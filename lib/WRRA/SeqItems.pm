package WRRA::SeqItems;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::Exception;

sub list {
	my $self = shift;

	my $rs = $self->db->resultset($self->param('results'));
	my $request = ref $self->merged ? $self->merged : {$self->merged};

	my $year = $rs->session->{year};
	my $start = $rs->session->{auctions}->{$year}->[0] or Mojo::Exception->throw("Cannot determine start date of auction $year");
	my $n = $self->param('n');

	my %search;
	$search{scheduled} = {'='=>undef} if not(defined $n) || $n <= 0 || $n =~ /\D/ || $start !~ /^\d{4}-\d{2}-\d{2}$/;
	$search{scheduled} = [{'='=>undef},{'!='=>undef}] if $n >= 9999;
	$n--;
	$search{scheduled} ||= {'='=>\"date_add('$start', interval $n day)"};
	$rs = $rs->search({%search}, {order_by=>{'-asc'=>['scheduled','seq']}})->current_year;

	$self->respond_to(
		json => {json => [$rs->all]},
		xls => sub { # With TO_XLS
			$self->cookie(fileDownload => 'true');
			$self->cookie(path => '/');
			$self->render_xls(result => $rs->all);
		},
	);
}

sub sequence {
	my $self = shift;

	my $rs = $self->db->resultset($self->param('results'));
	my $request = ref $self->merged ? $self->merged : {$self->merged};
	my @items = map { /_(\d+)$/; $1 } @{$request->{id}};

	my $year = $rs->session->{year};
	my $start = $rs->session->{auctions}->{$year}->[0] or Mojo::Exception->throw("Cannot determine start date of auction $year");
	my $n = $self->param('n');

	my %update;
	$update{seq} = \join('', 'FIND_IN_SET(item_id, "', join(',', @items), '")');
	if ( $n == 0 ) {
		$update{scheduled} = undef;
	} elsif ( $n > 0 and $n < 9999 ) {
		$n--;
		$update{scheduled} = \"date_add('$start', interval $n day)";
	}

	$self->respond_to(
		json => {json => {res=>($rs->search({item_id => {-in => [@items]}})->update({%update})?'ok':'err'),msg=>''}},
	);
}

1;
