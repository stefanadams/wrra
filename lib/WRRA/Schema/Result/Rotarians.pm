package WRRA::Schema::Result::Rotarians;

use base 'WRRA::Schema::Result::Rotarian';

use Lingua::EN::NameParse qw(clean case_surname);
my $name = new Lingua::EN::NameParse(auto_clean=>1,force_case=>1,lc_prefix=>1,initials=>1,allow_reversed=>1,joint_names=>0,extended_titles=>0);

# The columns to be rendered
sub FROM_JSON { qw/id name has_submissions email phone/ }

# The columns to be rendered as special accessor methods
#sub received { shift->SUPER::received->ymd }
#sub sold { shift->SUPER::sold ? 1 : 0 }

# These class methods are passed $r, $rs, $request
sub _create {
	my ($class, $r, $rs, $req) = @_;
	$r->rotarian_id($req->{id});
	return $r;
};
#sub _search { $_[1] };
#sub _update { $_[1] };
#sub _delete { $_[1] };

# The relationships associated with this result (table)
#our $relationships = [qw/donor stockitem/];

# When reading (i.e. searching or ordering), use this hashref to lookup references (scalar) or use mysql functions (scalarref)
# As a special case, if an arrayref is provided, index [0] is provided for search routines and index [1] is provided for ordering routines.
# If not an arrayref then the same handler is used for both search and ordering.
# if a coderef is provided, pass a hashref of the search condition to search or nothing to ordering.  Expects a fully formulated SQL::Abstract ref.
our $read = {
	'id' => 'rotarian_id',
	'name' => \'concat(lastname, firstname)',
};
# When editing (i.e. creating or updating), use this hashref to lookup coderefs and pass the value to provide and expect back a full hash of key/value pairs.
our $edit = {
	'name' => sub {
		my $value = shift;
		$error = $name->parse($value);
		my %name = $name->case_components;
		return (lastname => $name{surname_1}||'', firstname => $name{given_name_1}||'');
	},
};
# For each field being edited (i.e. created or updated) validate the value with the qr regex in this hashref
#our $validate = {};

1;
