package WRRA::Model::AcItemStockitem;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Item';

sub resultset { $_[1]->search({}, {prefetch=>'stockitem', group_by=>'stockitem.name', order_by=>'stockitem.name'})->current_year }

1;
