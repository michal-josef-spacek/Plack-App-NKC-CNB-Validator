use lib '.';
use strict;
use warnings;

use inc::Module::Install;

# Definition.
abstract 'Plack application for NKC Czech National Bibliography validation.';
author 'Michal Josef Spacek <michal.josef.spacek@gmail.com>';
author_requires 'File::Object' => 0.05;
author_requires 'Test::More' => 0;
author_requires 'Test::NoWarnings' => 0;
author_requires 'Test::Pod' => 0;
author_requires 'Test::Pod::Coverage' => 0;
license 'bsd';
name 'Plack-App-NKC-CNB-Validator';
readme_from 'Validator.pm';
recursive_author_tests('xt');
requires 'Class::Utils' => 0;
requires 'CPAN::Changes::Utils' => 0;
requires 'Data::HTML::Footer' => 0.02;
requires 'Data::MARC::Validator::Report' => 0;
requires 'Data::NKC::MARC::Menu' => 0;
requires 'Data::Message::Simple' => 0;
requires 'DateTime' => 0;
requires 'English' => 0;
requires 'Error::Pure' => 0;
requires 'Exporter' => 0;
requires 'List::Util' => 1.33;
requires 'MARC::File::XML' => 0;
requires 'MARC::Record' => 0;
requires 'MARC::Validator' => 0;
requires 'NKC::Id::Utils' => 0;
requires 'Plack::App::CPAN::Changes' => 0.03;
requires 'Plack::App::Search' => 0.04;
requires 'Plack::App::URLMap' => 0;
requires 'Plack::Component' => 0;
requires 'Plack::Request' => 0;
requires 'Plack::Session' => 0;
requires 'Plack::Util::Accessor' => 0;
requires 'Scalar::Util' => 0;
requires 'Tags::HTML::Container' => 0;
requires 'Tags::HTML::Footer' => 0.03;
requires 'Tags::HTML::MARC::Validator::Report' => 0;
requires 'Tags::HTML::Messages' => 0;
requires 'Tags::HTML::NKC::MARC::Menu' => 0;
requires 'Readonly' => 0;
requires 'Unicode::UTF8' => 0;
requires 'ZOOM' => 0;
resources 'bugtracker' => 'https://github.com/michal-josef-spacek/Plack-App-NKC-CNB-Validator/issues';
resources 'homepage' => 'https://github.com/michal-josef-spacek/Plack-App-NKC-CNB-Validator';
resources 'repository' => 'git://github.com/michal-josef-spacek/Plack-App-NKC-CNB-Validator';
test_requires 'Test::More' => 0;
test_requires 'Test::NoWarnings' => 0;
tests_recursive;
version '0.02';

# Run.
WriteAll();
