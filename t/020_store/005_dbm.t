use strict;
use warnings;
use Test::More tests => 2;
use Test::Exception;
use HTTP::Session;
use CGI;
use HTTP::Session::Store::DBM;
use HTTP::Session::State::Null;
use File::Temp;

my ($fh, $fname) = File::Temp::tempfile(UNLINK => 1);
my $session = HTTP::Session->new(
    store   => HTTP::Session::Store::DBM->new(
        file => $fname,
    ),
    state   => HTTP::Session::State::Null->new(),
    request => CGI->new,
);
$session->set( 'foo' => 'bar' );
is $session->get('foo'), 'bar';
$session->remove('foo');
is $session->get('foo'), undef;

