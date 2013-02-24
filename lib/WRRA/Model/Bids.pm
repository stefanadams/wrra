package WRRA::Model::Bids;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Bid';

sub resultset { $_[1]->current_year }

1;
