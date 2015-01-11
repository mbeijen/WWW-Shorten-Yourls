use Test::More;
use WWW::Shorten::Yourls;

plan skip_all => 'environment variable YOURLS_URL not set'
  if !$ENV{YOURLS_URL};

# add trailing slash to URL if missing
$ENV{YOURLS_URL} =~ s!/*$!/!;

my @testcredentials = (
  $ENV{YOURLS_USERNAME} || '',
  $ENV{YOURLS_PASSWORD} || '',
  $ENV{YOURLS_URL},
);

diag(
  sprintf(
    "\n YOURLS_USERNAME = '%s'" .
    "\n YOURLS_PASSWORD = '%s'" .
    "\n YOURLS_URL      = '%s'" .
    "\n YOURLS_API_KEY  = '%s'",
    @testcredentials, $ENV{YOURLS_API_KEY} || '*UNSET*'
  )
);

my $url = 'https://metacpan.org/release/WWW-Shorten';
my $return = makeashorterlink($url, @testcredentials);
my ($code) = $return =~ /(\w+)$/;
my $prefix = $ENV{YOURLS_URL};
is ( makeashorterlink($url, @testcredentials), $prefix.$code, "make it shorter: $return");
is ( makealongerlink($prefix.$code, @testcredentials), $url, 'make it longer');
is ( makealongerlink($code, @testcredentials), $url, 'make it longer by Id',);

eval { makeashorterlink() };
ok($@, 'makeashorterlink fails with no args');
eval { makealongerlink() };
ok($@, 'makealongerlink fails with no args');

my $yourls = WWW::Shorten::Yourls->new(
  USER     => $testcredentials[0],
  PASSWORD => $testcredentials[1],
  BASE     => $testcredentials[2],
);

ok ($yourls, 'Create new yourls-object with USER, PASSWORD, BASE');

$short = $yourls->shorten(URL => $url);

like ($short, qr/^\b${prefix}\b[a-zA-Z0-9]+/, 'created short link');

ok ($yourls->shorten(URL => $url), 'shorten() OO-usage');
like ($yourls->{url}, qr/^\b${prefix}\b[a-zA-Z0-9]+/, 'created short link');

my $original = $yourls->expand();
is ($original, $url, 'expand()');

my $secondurl = 'https://www.huntingbears.nl/';
my $secondshort = $yourls->shorten(URL => $secondurl);

like ($secondshort, qr/^\b${prefix}\b[a-zA-Z0-9]+/, 'created second short link');

is ($yourls->expand(URL=>$return), $url, "expand(URL=>'$return')");
is ($yourls->expand(URL=>$secondshort), $secondurl, "expand(URL=>'$secondshort')");

done_testing;
