package WRRA::Model::AcAdvertiser;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Donor';

sub resultset { $_[1]->search({}, {group_by=>'donor_id', order_by=>'name'}) }

1;
