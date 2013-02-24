package WRRA::View::SeqItems;

use base 'WRRA::View';

use Mojo::JSON;
use Data::Dumper;

sub search {
	my $class = shift;
	my $request = shift;
	my $resolver = shift;

	my ($start, $field, $string) = ($request->{start}, 'scheduled', $request->{n});

	my %search = ();

	if ( defined $resolver->{search}->{$field} ) {
		if ( ref $resolver->{search}->{$field} eq 'CODE' ) {
			$search{$field} = $resolver->{search}->{$field}->($start, $string);
		} else {
			warn "search resolver must be a coderef";
		}
	}

	return (%search);
}

sub key {
	my $class = shift;
	my $request = shift;
	my $resolver = shift;

	{item_id => {-in => [map { /_(\d+)$/; $1 } @{$request->{id}}]}}
}

sub update {
	my $class = shift;
	my $request = shift;
	my $resolver = shift;

	return (map {
		defined $_ && $resolver->{update_or_create}->{$_} && ref $resolver->{update_or_create}->{$_} eq 'CODE'
		? ($resolver->{update_or_create}->{$_}->($request->{$_}, $request, $resolver))
		: ($_ => $request->{$_})
	} (keys %$request));
}

1;
