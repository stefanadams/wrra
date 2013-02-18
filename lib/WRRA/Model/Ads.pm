package WRRA::Model::Ads;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Ad';

sub resultset { $_[1]->current_year }

1;
