package WRRA::Model::DonorItems;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Item';

sub search { donor_id => shift->app->param('id') }

1;
