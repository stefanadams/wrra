package WRRA::Model::AcItem;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Item';

sub resultset { $_[1]->search({}, {prefetch=>'donor', group_by=>'me.name', order_by=>'me.name'})->recent_years }

1;
