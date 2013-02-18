package WRRA::Model::Stockitems;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Stockitem';

sub resultset { $_[1]->current_year }

1;
