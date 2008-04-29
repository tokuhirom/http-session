use strict;
use warnings;
use Test::More;
use HTTP::Session::State::Cookie;
use HTTP::Request;
use HTTP::Response;

plan tests => 2;

my $conf = {name => 'sledge_sid', path => '/'};

{
    my $state = HTTP::Session::State::Cookie->new(config => $conf);
    my $req = HTTP::Request->new(
        'GET', '/', [
            Cookie => 'sledge_sid=ASDFASDF; path=/; expires=80800'
        ]
    );
    is($state->get_session_id($req), 'ASDFASDF');
}

{
    my $state = HTTP::Session::State::Cookie->new(config => $conf);
    my $res = HTTP::Response->new( 200, 'OK' );
    $state->inject_session_id($res, 'HOHOGEHOGE');
    is($res->header('Set-Cookie') , 'sledge_sid=HOHOGEHOGE; path=/');
}

