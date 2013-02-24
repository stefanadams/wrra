package WRRA::Model::AcAd;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Ad';

sub resultset { $_[1]->search({}, {prefetch=>'advertiser', group_by=>'me.advertiser_id', order_by=>'me.name'}) }

1;
