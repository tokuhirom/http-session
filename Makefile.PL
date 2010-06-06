use inc::Module::Install;
name 'HTTP-Session';
all_from 'lib/HTTP/Session.pm';

requires 'Class::Accessor::Fast' => 0.31;
requires 'CGI::Simple::Cookie' => 1.103;
requires 'Digest::SHA1'        => 2.11;
requires 'HTTP::Response'      => 5.818;
requires 'UNIVERSAL::require'  => 0.05;
requires 'URI'                 => 1.38;

recommends 'HTML::StickyQuery'               => 0.12; # State::URI
recommends 'HTTP::MobileAgent'               => 0.27; # State::MobileAgentID

tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::Requires';
test_requires 'Test::More';
test_requires 'Test::Exception';
author_tests('xt');
auto_set_repository();
auto_include;
WriteAll;
