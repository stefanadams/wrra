package WRRA::Model::Bidders;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Bidder';

sub resultset { $_[1]->current_year }

1;
