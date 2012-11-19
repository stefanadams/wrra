package MojoX::JSON2;

use Mojo::Base -base;

use B;
use Mojo::Util;
use Scalar::Util 'blessed';

has 'error';

# Literal names
my $FALSE = bless \(my $false = 0), 'Mojo::JSON::_Bool';
my $TRUE  = bless \(my $true  = 1), 'Mojo::JSON::_Bool';

# Escaped special character map (with u2028 and u2029)
my %ESCAPE = (
  '"'     => '"',
  '\\'    => '\\',
  '/'     => '/',
  'b'     => "\x07",
  'f'     => "\x0C",
  'n'     => "\x0A",
  'r'     => "\x0D",
  't'     => "\x09",
  'u2028' => "\x{2028}",
  'u2029' => "\x{2029}"
);
my %REVERSE = map { $ESCAPE{$_} => "\\$_" } keys %ESCAPE;
for (0x00 .. 0x1F, 0x7F) { $REVERSE{pack 'C', $_} //= sprintf '\u%.4X', $_ }

# Unicode encoding detection
my $UTF_PATTERNS = {
  'UTF-32BE' => qr/^\0\0\0[^\0]/,
  'UTF-16BE' => qr/^\0[^\0]\0[^\0]/,
  'UTF-32LE' => qr/^[^\0]\0\0\0/,
  'UTF-16LE' => qr/^[^\0]\0[^\0]\0/
};

my $WHITESPACE_RE = qr/[\x20\x09\x0a\x0d]*/;

sub decode {
  my ($self, $bytes) = @_;

  # Cleanup
  $self->error(undef);

  # Missing input
  $self->error('Missing or empty input') and return undef unless $bytes;

  # Remove BOM
  $bytes =~ s/^(?:\357\273\277|\377\376\0\0|\0\0\376\377|\376\377|\377\376)//g;

  # Wide characters
  $self->error('Wide character in input') and return undef
    unless utf8::downgrade($bytes, 1);

  # Detect and decode Unicode
  my $encoding = 'UTF-8';
  $bytes =~ $UTF_PATTERNS->{$_} and $encoding = $_ for keys %$UTF_PATTERNS;
  $bytes = Mojo::Util::decode $encoding, $bytes;

  # Object or array
  my $res = eval {
    local $_ = $bytes;

    # Leading whitespace
    m/\G$WHITESPACE_RE/gc;

    # Array
    my $ref;
    if (m/\G\[/gc) { $ref = _decode_array() }

    # Object
    elsif (m/\G\{/gc) { $ref = _decode_object() }

    # Unexpected
    else { _exception('Expected array or object') }

    # Leftover data
    unless (m/\G$WHITESPACE_RE\z/gc) {
      my $got = ref $ref eq 'ARRAY' ? 'array' : 'object';
      _exception("Unexpected data after $got");
    }

    $ref;
  };

  # Exception
  if (!$res && (my $e = $@)) {
    chomp $e;
    $self->error($e);
  }

  return $res;
}

sub encode {
  my ($self, $ref) = @_;
  return Mojo::Util::encode 'UTF-8', _encode_values($self, $ref);
}

sub false {$FALSE}
sub true  {$TRUE}

sub _decode_array {
  my @array;
  until (m/\G$WHITESPACE_RE\]/gc) {

    # Value
    push @array, _decode_value();

    # Separator
    redo if m/\G$WHITESPACE_RE,/gc;

    # End
    last if m/\G$WHITESPACE_RE\]/gc;

    # Invalid character
    _exception('Expected comma or right square bracket while parsing array');
  }

  return \@array;
}

sub _decode_object {
  my %hash;
  until (m/\G$WHITESPACE_RE\}/gc) {

    # Quote
    m/\G$WHITESPACE_RE"/gc
      or _exception('Expected string while parsing object');

    # Key
    my $key = _decode_string();

    # Colon
    m/\G$WHITESPACE_RE:/gc
      or _exception('Expected colon while parsing object');

    # Value
    $hash{$key} = _decode_value();

    # Separator
    redo if m/\G$WHITESPACE_RE,/gc;

    # End
    last if m/\G$WHITESPACE_RE\}/gc;

    # Invalid character
    _exception('Expected comma or right curly bracket while parsing object');
  }

  return \%hash;
}

sub _decode_string {
  my $pos = pos;

  # Extract string with escaped characters
  m#\G(((?:[^\x00-\x1F\\"]|\\(?:["\\/bfnrt]|u[[:xdigit:]]{4})){0,32766})*)#gc;
  my $str = $1;

  # Missing quote
  unless (m/\G"/gc) {
    _exception('Unexpected character or invalid escape while parsing string')
      if m/\G[\x00-\x1F\\]/;
    _exception('Unterminated string');
  }

  # Unescape popular characters
  if (index($str, '\\u') < 0) {
    $str =~ s!\\(["\\/bfnrt])!$ESCAPE{$1}!gs;
    return $str;
  }

  # Unescape everything else
  my $buffer = '';
  while ($str =~ m/\G([^\\]*)\\(?:([^u])|u(.{4}))/gc) {
    $buffer .= $1;

    # Popular character
    if ($2) { $buffer .= $ESCAPE{$2} }

    # Escaped
    else {
      my $ord = hex $3;

      # Surrogate pair
      if (($ord & 0xF800) == 0xD800) {

        # High surrogate
        ($ord & 0xFC00) == 0xD800
          or pos($_) = $pos + pos($str), _exception('Missing high-surrogate');

        # Low surrogate
        $str =~ m/\G\\u([Dd][C-Fc-f]..)/gc
          or pos($_) = $pos + pos($str), _exception('Missing low-surrogate');

        # Pair
        $ord = 0x10000 + ($ord - 0xD800) * 0x400 + (hex($1) - 0xDC00);
      }

      # Character
      $buffer .= pack 'U', $ord;
    }
  }

  # The rest
  return $buffer . substr $str, pos($str), length($str);
}

sub _decode_value {

  # Leading whitespace
  m/\G$WHITESPACE_RE/gc;

  # String
  return _decode_string() if m/\G"/gc;

  # Array
  return _decode_array() if m/\G\[/gc;

  # Object
  return _decode_object() if m/\G\{/gc;

  # Number
  return 0 + $1
    if m/\G([-]?(?:0|[1-9][0-9]*)(?:\.[0-9]*)?(?:[eE][+-]?[0-9]+)?)/gc;

  # True
  return $TRUE if m/\Gtrue/gc;

  # False
  return $FALSE if m/\Gfalse/gc;

  # Null
  return undef if m/\Gnull/gc;

  # Invalid data
  _exception('Expected string, array, object, number, boolean or null');
}

sub _encode_array {
  my $self = shift;
  return '[' . join(',', map { _encode_values($self, $_) } @{shift()}) . ']';
}

sub _encode_object {
  my $self = shift;
  my $object = shift;

  # Encode pairs
  my @pairs = map { _encode_string($_) . ':' . _encode_values($self, $object->{$_}) }
    keys %$object;

  # Stringify
  return '{' . join(',', @pairs) . '}';
}

sub _encode_string {
  my $string = shift;

  # Escape string
  $string =~ s!([\x00-\x1F\x7F\x{2028}\x{2029}\\"/\b\f\n\r\t])!$REVERSE{$1}!gs;

  # Stringify
  return "\"$string\"";
}

sub _encode_values {
  my $self = shift;
  my $value = shift;

  # Reference
  if (my $ref = ref $value) {

    # Array
    return _encode_array($self, $value) if $ref eq 'ARRAY';

    # Object
    return _encode_object($self, $value) if $ref eq 'HASH';

    # True or false
    return $$value ? 'true' : 'false' if $ref eq 'SCALAR';
    return $value  ? 'true' : 'false' if $ref eq 'Mojo::JSON::_Bool';

    # Blessed reference with TO_JSON method
    if (blessed $value && (my $sub = $value->can('TO_JSON'))) {
      return 'null' if grep { $_ eq ref $value } @{$self->{__TO_JSON_DEPTH}};
      push @{$self->{__TO_JSON_DEPTH}}, ref $value;
      my $to_json = _encode_values($self, $value->$sub($self));
      pop @{$self->{__TO_JSON_DEPTH}} unless ref $to_json;
      return $to_json;
    }
  }

  # Null
  return 'null' unless defined $value;

  # Number
  my $flags = B::svref_2object(\$value)->FLAGS;
  return $value
    if $flags & (B::SVp_IOK | B::SVp_NOK) && !($flags & B::SVp_POK);

  # String
  return _encode_string($value);
}

sub json_ancestor {
  my $self = shift;
  return $self->{__TO_JSON_DEPTH}->[$_[0]] if $_[0] =~ /^-?\d$/;
  return grep { $_ eq $_[0] } @{$self->{__TO_JSON_DEPTH}} if $_[0];
  return @{$self->{__TO_JSON_DEPTH}};
}

sub _exception {

  # Leading whitespace
  m/\G$WHITESPACE_RE/gc;

  # Context
  my $context = 'Malformed JSON: ' . shift;
  if (m/\G\z/gc) { $context .= ' before end of data' }
  else {
    my @lines = split /\n/, substr($_, 0, pos);
    $context .= ' at line ' . @lines . ', offset ' . length(pop @lines || '');
  }

  # Throw
  die "$context\n";
}

# Emulate boolean type
package Mojo::JSON::_Bool;
use overload '0+' => sub { ${$_[0]} }, '""' => sub { ${$_[0]} }, fallback => 1;

package Mojolicious::Plugin::JSON2;

use Mojo::Base 'Mojolicious::Plugin';

our $VERSION = '0.01';

# You just have to give guys a chance. Sometimes you meet a guy and
# think he's a pig, but then later on you realize he actually has a
# really good body.
sub json2_renderer {
  my ($r, $c, $output, $options) = @_;

  # don't let MojoX::Renderer to encode output to string
  delete $options->{encoding};

  $$output = MojoX::JSON2->new->encode($c->stash->{json2});
}

sub register {
  my ($self, $app) = @_;

  $app->types->type(json2 => 'application/json');
  $app->renderer->add_handler(json2 => \&json2_renderer);
  $app->helper(
    render_json2 => sub {
      shift->render(handler => 'json2', @_);
    }
  );
}

1;
__END__

=head1 NAME

Mojolicious::Plugin::WriteExcel - write Excel spreadsheets from Mojolicious

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('write_excel');

  # Mojolicious::Lite
  plugin 'write_excel';

  # Render a spreadsheet
  get '/example.xls' => sub {
    shift->render(
      handler => 'xls',
      result  => [[qw(foo bar baz)], [qw(lol wut bbq)], [qw(kick ass module)],],
    );
  };


=head1 DESCRIPTION

L<Mojolicious::Plugin::WriteExcel> is a plugin for writing Excel
spreadsheets.

This plugin converts the C<result> element in the stash to an Excel
spreadsheet.  If the stash also has a C<heading> element, the renderer
will also write headings in bold type for the columns in the
spreadsheet.

C<heading> is an arrayref, while C<result> is an array of arrayrefs.

Optionally, a C<settings> parameter can be provided to set additional
attributes in the Excel spreadsheet.  Currently 'column_width' is the
only working attribute.  C<settings> is a hashref.  Column widths
could be set by passing the settings to C<render>:

  get '/colwidth.xls' => sub {
    shift->render(
      handler  => 'xls',
      result   => [['small'], ['medium'], ['large']],
      settings => {column_width => {'A:A' => 10, 'B:B' => 25, 'C:D' => 40}},
    );
  };
  settings => {column_width => {'A:A' => 10, 'B:B' => 25, 'C:D' => 40}}

=head1 METHODS

L<Mojolicious::Plugin::WriteExcel> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 C<xls_renderer>

  $app->renderer->add_handler(xls => \&xls_renderer);

Internal sub talking to L<Spreadsheet::WriteExcel::Simple> to render
spreadsheets.

=head2 C<register>

  $plugin->register;

Register renderer in L<Mojolicious> application.

=head1 ACKNOWLEDGEMENTS

Thanks to Graham Barr and his L<MojoX::Renderer::YAML> module, and
Sebastian Riedel's core L<Mojolicious::Plugin::EpRenderer> for showing
how to write renderers for L<Mojolicious>!

Inspiration for this renderer came from this mailing list thread:
L<http://www.mail-archive.com/plug@lists.linux.org.ph/msg21881.html>

=head1 SEE ALSO

L<Mojolicious>, L<Spreadsheet::WriteExcel::Simple>, L<http://mojolicious.org>.

=cut
