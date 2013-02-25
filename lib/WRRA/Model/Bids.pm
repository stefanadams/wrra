package WRRA::Model::Bids;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Bid';

sub resultset { $_[1]->search({})->search_related('item')->current_year }

1;
