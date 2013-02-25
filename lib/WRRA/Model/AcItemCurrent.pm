package WRRA::Model::AcItemCurrent;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Item';

sub resultset { $_[1]->search({}, {prefetch=>'donor', group_by=>'me.name', order_by=>'me.name'})->current_year }

1;
