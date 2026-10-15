use lib '.';
use strict;
use warnings;

use inc::Module::Install;

# Definition.
abstract 'XXX';
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
requires 'NKC::Id::Utils' => 0;
resources 'bugtracker' => 'https://github.com/michal-josef-spacek/Plack-App-NKC-CNB-Validator/issues';
resources 'homepage' => 'https://github.com/michal-josef-spacek/Plack-App-NKC-CNB-Validator';
resources 'repository' => 'git://github.com/michal-josef-spacek/Plack-App-NKC-CNB-Validator';
test_requires 'Test::More' => 0;
test_requires 'Test::NoWarnings' => 0;
tests_recursive;
version '0.01';

# Run.
WriteAll();
