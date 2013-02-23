package WRRA::View;

use Mojo::Util qw/camelize decamelize/;
use Data::Dumper;

our $view;
our $request;
our $resolver;
our %plugins;

sub set {
	my $class = shift;
	$view = $_[0] if $_[0];
	return $view;
}

sub request {
	my $class = shift;
	if ( ref $_[0] eq 'HASH' ) {
		#warn Dumper({request => $_[0]});
		return $request = $_[0];
	} elsif ( not ref $_[0] ) {
		#warn Dumper({request => [@_]});
		if ( @_ % 2 == 0 ) {
			#warn Dumper({request => {@_}});
			return $request = {@_};
		} else {
			#warn Dumper({request => {$_[0] => $request->{$_[0]}}});
			return $request->{$_[0]};
		}
	}
	die;
}

sub resolver {
	my $class = shift;
	if ( ref $_[0] eq 'HASH' ) {
		#warn Dumper({resolver => $_[0]});
		return $resolver = $_[0];
	} elsif ( not ref $_[0] ) {
		#warn Dumper({resolver => [@_]});
		if ( @_ % 2 == 0 ) {
			#warn Dumper({resolver => {@_}});
			return $resolver = {@_};
		} else {
			#warn Dumper({resolver => {$_[0] => $resolver->{$_[0]}}});
			return $resolver->{$_[0]};
		}
	}
	die;
}

sub validate {
	my $class = shift;
	foreach ( keys %{$request} ) {
		return $_ unless $request->{$_} =~ $resolver->{validate}->{$_}
	}
}

sub AUTOLOAD {
	my $class = shift;
	our $AUTOLOAD;
	return if $AUTOLOAD =~ /::DESTROY$/;
	my ($method) = $AUTOLOAD =~ m/.*::(\w+)$/;
	return () unless $view;
	my $plugin = join '::', __PACKAGE__, camelize($view);
	unless ( $plugins{$plugin} ) {
		eval "use $plugin";
		if ( $@ ) {
			();
		} else {
			$plugins{$plugin} = 1;
		}
	}
	if ( $plugin->can($method) ) {
		$plugin->$method($request, $resolver, @_);
	} else {
		();
	}
}

1;
