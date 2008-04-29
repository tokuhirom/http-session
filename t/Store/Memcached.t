use strict;
use warnings;
use Test::More;
plan skip_all => "ENV{TEST_MEMCACHED} does not set." unless $ENV{TEST_MEMCACHED};
plan tests => 3;
require HTTP::Session::Store::Memcached;

my $conf = {
    args => {
        servers => ['127.0.0.1:11211'],
    },
    exptime => 100,
};

my $session_id = 'testing' . rand();

{
    my $store = HTTP::Session::Store::Memcached->new(config => $conf);
    ok $store->does('HTTP::Session::Role::Store');
    is_deeply $store->load_session($session_id), {};
    $store->save_session( $session_id, {hoge => 'fuga'} );
    undef $store;
}

{
    my $store = HTTP::Session::Store::Memcached->new(config => $conf);
    is_deeply $store->load_session($session_id), {hoge => 'fuga'};
}

