use strict;
use Test::More tests => 3;

BEGIN {
    use_ok 'HTTP::Session';
    use_ok 'HTTP::Session::Role::State';
    use_ok 'HTTP::Session::Role::Store';
}

