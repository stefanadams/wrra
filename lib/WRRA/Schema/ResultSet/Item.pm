package WRRA::Schema::ResultSet::Item;

use base 'WRRA::Schema::ResultSet';

my ($nu, $nn) = ({'='=>undef},{'!='=>undef});

sub complete { shift->search({scheduled=>$nn,started=>$nn,sold=>$nn,cleared=>$nn}) }
sub paid { shift->search({scheduled=>$nn,started=>$nn,sold=>$nn,$paid=>$nn}) }
sub sold_not_paid { shift->search({scheduled=>$nn,started=>$nn,sold=>$nn,paid=>$nu}) }
sub sold { shift->search({scheduled=>$nn,started=>$nn,sold=>$nn}) }
sub bidding { shift->search({scheduled=>$nn,auctioneer=>$nn,started=>$nn,sold=>$nu}) }
sub on_deck { shift->search({scheduled=>$nn,auctioneer=>$nn,started=>$nu}) }
sub ready { shift->search({scheduled=>$nn,auctioneer=>$nu}) }
sub not_ready { shift->search({scheduled=>$nu}) }

1;
