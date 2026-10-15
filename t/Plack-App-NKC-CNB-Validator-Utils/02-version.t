use strict;
use warnings;

use Plack::App::NKC::CNB::Validator::Utils;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($Plack::App::NKC::CNB::Validator::Utils::VERSION, 0.01, 'Version.');
