package WRRA::Schema::Result::Donors;

use base 'WRRA::Schema::Result::Donor';

# The columns to be rendered
sub FROM_JSON { qw/id chamberid phone category name contact address city state zip email url advertisement solicit ly_items rotarian.id rotarian.name comments/ }

# The columns to be rendered as special accessor methods
#sub received { shift->SUPER::received->ymd }
#sub sold { shift->SUPER::sold ? 1 : 0 }

# These class methods are passed $rs, $request
#sub _create { $_[1] };
#sub _search { $_[1] };
#sub _update { $_[1] };
#sub _delete { $_[1] };

# The relationships associated with this result (table)
our $relationships = [qw/rotarian/];

# When reading (i.e. searching or ordering), use this hashref to lookup references (scalar) or use mysql functions (scalarref)
# As a special case, if an arrayref is provided, index [0] is provided for search routines and index [1] is provided for ordering routines.
# If not an arrayref then the same handler is used for both search and ordering.
# if a coderef is provided, pass a hashref of the search condition to search or nothing to ordering.  Expects a fully formulated SQL::Abstract ref.
our $read = {
	'rotarian.name' => \'concat(rotarian.lastname, rotarian.firstname)',
};
# When editing (i.e. creating or updating), use this hashref to lookup coderefs and pass the value to provide and expect back a full hash of key/value pairs.
#our $edit = {};
# For each field being edited (i.e. created or updated) validate the value with the qr regex in this hashref
#our $validate = {};

1;
