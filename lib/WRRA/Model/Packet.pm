package WRRA::Model::Packet;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Donor';

sub resultset { $_[1]->search({}, {order_by=>{'-asc'=>'name'}})->solicit }

1;
