use inc::Module::Install;
name 'HTTP-Session';
all_from 'lib/HTTP/Session.pm';

requires 'Moose'               => 0.59;
requires 'CGI::Simple::Cookie' => 1.103;
requires 'Digest::SHA1'        => 2.11;
requires 'HTML::StickyQuery'   => 0.12;
requires 'HTML::StickyQuery::DoCoMoGUID'   => 0.01;
requires 'HTTP::Response'      => 5.818;

tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::More';
test_requires 'Test::Exception';
test_requires 'YAML';
author_tests('xt');
use_test_base;
auto_include;
WriteAll;
