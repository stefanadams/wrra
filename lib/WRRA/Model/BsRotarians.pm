package WRRA::Model::BsRotarians;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Rotarian';

sub resultset { $_[1]->search({}, {order_by=>'lastname'}) }

1;
