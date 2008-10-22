use inc::Module::Install;
name 'HTTP-Session';
all_from 'lib/HTTP/Session.pm';

requires 'Moose' => 0.59;
requires 'CGI::Cookie' => 1.29;

tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::More';
test_requires 'Test::Exception';
test_requires 'YAML';
author_tests 'xt';
use_test_base;
auto_include;
WriteAll;
