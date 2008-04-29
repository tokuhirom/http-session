package HTTP::Session::Role::Store;
use strict;
use Moose::Role;

requires 'load_session', 'save_session';

has config => (
    is       => 'rw',
    isa      => 'HashRef',
    required => 1,
);

1;
