package WRRA::Model::AcStockitem;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Stockitem';

sub resultset { $_[1]->search({}, {group_by=>'name', order_by=>'name'})->current_year }

1;
