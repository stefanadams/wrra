package WRRA::Model::AcBellitem;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Bellitem';

sub resultset { $_[1]->search({}, {group_by=>'name', order_by=>'name'}) }

1;
