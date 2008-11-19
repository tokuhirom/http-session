use inc::Module::Install;
name 'HTTP-Session';
all_from 'lib/HTTP/Session.pm';

requires 'Class::Accessor::Fast' => 0.31;
requires 'CGI::Simple::Cookie' => 1.103;
requires 'Digest::SHA1'        => 2.11;
requires 'HTML::StickyQuery'   => 0.12;
requires 'HTTP::MobileAttribute'           => 0.07;
requires 'HTML::StickyQuery::DoCoMoGUID'   => 0.01;
requires 'HTTP::Response'      => 5.818;
requires 'UNIVERSAL::require'  => 0.05;

tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::More';
test_requires 'Test::Exception';
test_requires 'YAML';
author_tests('xt');
use_test_base;
auto_include;
WriteAll;
