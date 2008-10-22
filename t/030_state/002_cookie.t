use strict;
use warnings;
use Test::More tests => 6;
use Test::Exception;
use HTTP::Session;
use HTTP::Session::Store::Memory;
use HTTP::Session::State::Cookie;
use HTTP::Response;
use CGI;

sub {
    local $ENV{HTTP_COOKIE} = 'http_session_sid=bar; path=/;';

    my $session = HTTP::Session->new(
        store   => HTTP::Session::Store::Memory->new,
        state   => HTTP::Session::State::Cookie->new(),
        request => CGI->new
    );
    $session->load_session;
    is $session->session_id(), 'bar';
    my $res = HTTP::Response->new(200, 'foo');
    $session->response_filter($res);
    is $res->header('Set-Cookie'), 'http_session_sid=bar; path=/';
}->();

sub {
    local $ENV{HTTP_COOKIE} = '';

    my $session = HTTP::Session->new(
        store   => HTTP::Session::Store::Memory->new,
        state   => HTTP::Session::State::Cookie->new(),
        request => CGI->new
    );
    $session->load_session;
    like $session->session_id(), qr/^[a-z0-9]{32}$/, 'cookie not found';
}->();

sub {
    local $ENV{HTTP_COOKIE} = 'foo_sid=bar; path=/admin/;';

    my $session = HTTP::Session->new(
        store => HTTP::Session::Store::Memory->new,
        state => HTTP::Session::State::Cookie->new(
            cookie_name   => 'foo_sid',
            cookie_path   => '/admin/',
            cookie_domain => 'example.com',
        ),
        request => CGI->new
    );
    $session->load_session;
    is $session->session_id, 'bar';
    my $res = HTTP::Response->new(200, 'foo');
    $session->response_filter($res);
    is $res->header('Set-Cookie'), 'foo_sid=bar; domain=example.com; path=/admin/';
}->();

sub {
    local $ENV{HTTP_COOKIE} = 'foo_sid=bar; path=/admin/;';

    my $session = HTTP::Session->new(
        store => HTTP::Session::Store::Memory->new,
        state => HTTP::Session::State::Cookie->new(),
        request => CGI->new
    );
    throws_ok {$session->state->response_filter() } qr/missing session_id/;
}->();

