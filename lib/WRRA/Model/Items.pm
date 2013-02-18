package WRRA::Model::Items;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Item';

sub resultset { $_[1]->search({}, {prefetch=>[qw/donor stockitem/]})->current_year }

1;
