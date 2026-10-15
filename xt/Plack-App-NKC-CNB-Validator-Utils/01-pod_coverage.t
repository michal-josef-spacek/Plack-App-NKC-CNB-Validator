use strict;
use warnings;

use Test::NoWarnings;
use Test::Pod::Coverage 'tests' => 2;

# Test.
pod_coverage_ok('Plack::App::NKC::CNB::Validator::Utils', 'Plack::App::NKC::CNB::Validator::Utils is covered.');
