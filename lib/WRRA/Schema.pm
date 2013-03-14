use utf8;
package WRRA::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces(
    default_resultset_class => "ResultSet",
);


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-03-13 14:14:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HYB4fWjD846xhsZd5rN3gg

__PACKAGE__->load_components(qw(Helper::Schema::ResultSet Helper::Schema::Mojolicious));

our $defaults = {
	recent_years => 2,
};

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
