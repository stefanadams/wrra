sub default { shift->search({}, {group_by=>'city', order_by=>'city'}) }
