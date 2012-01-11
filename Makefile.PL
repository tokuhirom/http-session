use inc::Module::Install;
name 'HTTP-Session';
all_from 'lib/HTTP/Session.pm';

requires 'Class::Accessor::Fast' => 0.31;
requires 'CGI::Simple::Cookie' => 1.103;
requires 'Digest::SHA1'        => 2.11;
requires 'HTTP::Response'      => 5.818;
requires 'Module::Runtime'     => 0.011;
requires 'URI'                 => 1.38;
requires 'Exporter'            => 5.63; # depend to latest Exporter for 'use Exporter "import"'.

recommends 'HTML::StickyQuery'               => 0.12; # State::URI

tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::Requires';
test_requires 'Test::More';
author_tests('xt');
auto_set_repository();
WriteAll;
