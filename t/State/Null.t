use strict;
use warnings;
use Test::More;
use HTTP::Session::State::Null;
use HTTP::Request;
use HTTP::Response;

plan tests => 1;

my $conf = {};

{
    my $state = HTTP::Session::State::Null->new(config => $conf);
    my $req = HTTP::Request->new( 'GET', '/' );
    ok !$state->get_session_id($req);
}

{
    my $state = HTTP::Session::State::Null->new(config => $conf);
    my $res = HTTP::Response->new( 200, 'OK' );
    $state->inject_session_id($res, 'HOHOGEHOGE');
}

