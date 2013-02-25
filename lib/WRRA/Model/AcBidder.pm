package WRRA::Model::AcBidder;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Bidder';

sub resultset { $_[1]->search({}, {group_by=>'me.bidder_id', order_by=>'me.name'}) }

1;
