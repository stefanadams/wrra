package WRRA::Model::SeqItems;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Item';

sub resultset { $_[1]->search({}, {order_by=>{'-asc'=>['scheduled','seq']}})->current_year }

1;
