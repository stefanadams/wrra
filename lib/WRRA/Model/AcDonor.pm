package WRRA::Model::AcDonor;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Donor';

sub resultset { $_[1]->search({}, {group_by=>'me.donor_id', order_by=>'me.name'}) }

1;
