# $Id$

use strict;

use Parrot::Test tests => 2;

# Test some regular expressions needed for parsing m4-input files.
{
  pir_output_is( << 'END_PIR', << 'OUTPUT', "call parrot and do something" );
.sub _main
  print	42
  print	"\n"
  end
.end
END_PIR
42
OUTPUT
}

# Test loading of pcre library, Perl compatible regular expressions
{
  pir_output_is( << 'END_PIR', << 'OUTPUT', "call parrot and do something" );
.include "library/pcre.imc"
.sub _main
  print	"\n"
  .local pmc lib
  .PCRE_INIT(lib)
  .local string error
  .local int errptr
  .local pmc code
  .local string pat
  pat = "asdf"
  .PCRE_COMPILE(pat, 0, code, error, errptr)
  $I0 = defined code
  unless $I0 goto match_err

  .local int ok
  .local pmc result
  .local string s
  s = "0123asdf89"
  .PCRE_MATCH(code, s, 0, 0, ok, result)
  if ok < 0 goto nomatch
  print ok
  print " match(es):\n"
  .local int i
  i = 0
  .local string match
  .local string s
lp: .PCRE_DOLLAR(s, ok, result, i, match)
  print match
  print "\n"
  inc i
  if i < ok goto lp
  end
nomatch:
  print "no match\n"
  end
match_err:
  print "error in regex: "
  print "at: '"
  length $I0, pat
  $I0 = $I0 - errptr
  substr $S0, pat, errptr, $I0
  print $S0
  print "'\n"
  exit 1
.end
END_PIR

1 match(es):
asdf
OUTPUT
}
