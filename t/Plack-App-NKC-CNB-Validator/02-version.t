use strict;
use warnings;

use Plack::App::NKC::CNB::Validator;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($Plack::App::NKC::CNB::Validator::VERSION, 0.03, 'Version.');
