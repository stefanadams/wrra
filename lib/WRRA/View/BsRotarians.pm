package WRRA::View::BsRotarians;

use Data::Dumper;

sub read {
	my $class = shift;
	my $request = shift;
	my $resolver = shift;

	build_select => sub {
		my $self = shift;
		return <<EOF;
<select>
  <option value="" />
  % foreach ( $self->all ) {
      <option value="<%= $_->rotarian_id %>"><%= $_->name %></option>
  % } 
</select>
EOF
	}
}

1;
