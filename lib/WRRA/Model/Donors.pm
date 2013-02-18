package WRRA::Model::Donors;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Donor';

sub resultset { $_[1]->search({}, {prefetch=>'rotarian'}) }

1;
