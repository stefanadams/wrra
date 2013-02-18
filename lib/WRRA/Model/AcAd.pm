package WRRA::Model::AcAd;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Ad';

sub resultset { $_[1]->search({}, {group_by=>'name', order_by=>'name'})->current_year }

1;
