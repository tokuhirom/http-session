use strict;
use warnings;
use Test::More tests => 1;
use HTTP::Session;
use HTTP::Request;
use HTTP::Response;

my $req = HTTP::Request->new('GET', '/');
my $res = HTTP::Response->new(200, '');

my $session = HTTP::Session->new(
    config => { store => { module => 'Null' }, state => { module => 'Null' } },
    req    => $req
);
$session->inject_session_id( $res );

ok 1;
