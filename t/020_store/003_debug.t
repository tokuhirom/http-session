use strict;
use warnings;
use Test::More tests => 4;
use Test::Exception;
use HTTP::Session;
use CGI;
use HTTP::Session::Store::Debug;
use HTTP::Session::State::Null;

my $session = HTTP::Session->new(
    store   => HTTP::Session::Store::Debug->new(),
    state   => HTTP::Session::State::Null->new(),
    request => CGI->new,
);
for my $meth (qw/select update delete insert/) {
    throws_ok { $session->store->$meth() } qr/missing session_id/;
}
