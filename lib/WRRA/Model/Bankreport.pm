package WRRA::Model::Bankreport;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Item';

sub search { year => shift->app->param('year') }

1;
