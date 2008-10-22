package HTTP::Session::Role::Store;
use Moose::Role;

requires qw/select insert update delete/;

1;
