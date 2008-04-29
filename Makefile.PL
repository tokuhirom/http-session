use inc::Module::Install;
name 'HTTP-Session';
all_from 'lib/HTTP/Session.pm';

requires 'Moose' => 0.14;
requires 'UNIVERSAL::require' => 0.11;

tests 't/*.t t/*/*.t t/*/*/*.t';
build_requires 'Test::More';
build_requires 'YAML';
use_test_base;
auto_include;
WriteAll;
