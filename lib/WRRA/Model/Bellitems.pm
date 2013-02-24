package WRRA::Model::Bellitems;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Bellitem';

sub resultset { $_[1]->current_year }

1;
