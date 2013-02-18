package WRRA::Model::AcAdvertisement;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Donor';

sub resultset { $_[1]->search({}, {group_by=>'advertisement', order_by=>'advertisement'}) }

1;
