package HTTP::Session::Role::State;
use strict;
use Moose::Role;

requires 'get_session_id', 'inject_session_id';

has 'store' => (
    is   => 'rw',
    does => 'HTTP::Session::Role::Store',
);

has config => (
    is       => 'rw',
    isa      => 'HashRef',
    required => 1,
);

1;
