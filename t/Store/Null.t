use strict;
use warnings;
use Test::More tests => 4;
use HTTP::Session::Store::Null;

my $store = HTTP::Session::Store::Null->new(session_id => 'hoge', config => {});
ok $store->does('HTTP::Session::Role::Store');
ok $store->can('load_session');
ok $store->can('save_session');

is_deeply $store->load_session(), {};
$store->save_session();

