package WRRA::Model::DonorItems;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Item';

#sub resultset { $_[1]->search({}, {order_by=>['year desc', 'sold asc']}) }
#sub search { warn; donor_id => shift->app->param('id') }

1;
