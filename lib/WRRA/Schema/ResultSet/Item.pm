package WRRA::Schema::ResultSet::Item;

use base 'WRRA::Schema::ResultSet';

my ($nu, $nn) = ({'='=>undef},{'!='=>undef});

sub auctioneer { shift->search({auctioneer=>shift}, {order_by=>'seq'}) }

sub complete { shift->search({scheduled=>$nn,started=>$nn,sold=>$nn,cleared=>$nn}, {order_by=>'number'}) }
sub paid { shift->search({scheduled=>$nn,started=>$nn,sold=>$nn,$paid=>$nn}, {order_by=>'number'}) }
sub unpaid { shift->search({scheduled=>$nn,started=>$nn,sold=>$nn,paid=>$nu}, {order_by=>'number'}) }
sub sold { shift->search({scheduled=>$nn,started=>$nn,sold=>$nn}, {order_by=>'number'}) }
sub bidding { shift->search({scheduled=>$nn,auctioneer=>$nn,started=>$nn,cleared=>$nu}, {order_by=>'number'}) }
sub on_deck { shift->search({scheduled=>$nn,auctioneer=>$nn,started=>$nu}, {order_by=>'number'}) }
sub ready { shift->search({scheduled=>$nn,auctioneer=>$nu}, {order_by=>'number'}) }
sub not_ready { shift->search({scheduled=>$nu}, {order_by=>'number'}) }

1;
