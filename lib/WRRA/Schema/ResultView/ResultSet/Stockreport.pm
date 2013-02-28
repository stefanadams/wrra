sub default { shift->search({}, {'+select'=>[{count=>'me.value'},{sum=>'me.value'},{sum=>'me.cost'}],'+as'=>['count','tvalue','tcost'],join=>'items',group_by=>'me.stockitem_id'})->current_year }
