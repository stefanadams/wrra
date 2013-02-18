package WRRA::Model::AcPayNumber;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Donor';

sub resultset { $_[1]->search({}, {group_by=>'city', order_by=>'city'}) }

1;
