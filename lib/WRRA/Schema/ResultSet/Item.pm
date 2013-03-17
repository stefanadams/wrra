package WRRA::Schema::ResultSet::Item;

use base 'WRRA::Schema::ResultSet';

my ($nu, $nn) = ({'='=>undef},{'!='=>undef});

sub auctioneer {
	my ($self, $auctioneer) = @_;
	$auctioneer ||= $nn;
	$self->search({auctioneer=>$auctioneer}, {order_by=>[qw/seq number/], rows=>$self->session->{auctioneer_limit}||10});
}

sub complete { shift->search({scheduled=>$nn,started=>$nn,sold=>$nn,cleared=>$nn}, {order_by=>'number'}) }
sub verifying { shift->search({scheduled=>$nn,started=>$nn,sold=>$nn,contacted=>$nn}, {order_by=>'number'}) }
sub paid { shift->search({scheduled=>$nn,started=>$nn,sold=>$nn,$paid=>$nn}, {order_by=>'number'}) }
sub unpaid { shift->search({scheduled=>$nn,started=>$nn,sold=>$nn,paid=>$nu}, {order_by=>'number'}) }
sub sold { shift->search({scheduled=>$nn,started=>$nn,sold=>$nn}, {order_by=>'number'}) }
sub bidding { shift->search({scheduled=>$nn,auctioneer=>$nn,started=>$nn,cleared=>$nu}, {order_by=>'number'}) }
sub ondeck { shift->search({scheduled=>$nn,auctioneer=>$nn,started=>$nu}, {order_by=>'number'}) }
sub ready { shift->search({scheduled=>$nn,auctioneer=>$nu}, {order_by=>'number', rows=>10}) }
sub staged { shift->search({scheduled=>$nu}, {order_by=>'number'}) }

1;
