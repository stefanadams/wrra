package WRRA::Model::Stockreport;
use Mojo::Base 'WRRA::Model::Base';

has resultset_class => 'Stockitem';

sub resultset { $_[1]->search({}, {'+select'=>[{count=>'me.value'},{sum=>'me.value'},{sum=>'me.cost'}],'+as'=>['count','tvalue','tcost'],join=>'items',group_by=>'me.stockitem_id'})->current_year }

1;

__END__
select stockitems.name,count(*),sum(stockitems.value),sum(stockitems.cost) from stockitems join items using (stockitem_id) where stockitems.year=2012 group by stockitems.stockitem_id;
