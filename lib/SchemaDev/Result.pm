package Schema::Result;

use base 'DBIx::Class::Core';

sub mk_hash { map { $_=>$_[0]->$_ } $_[0]->columns }

1;
