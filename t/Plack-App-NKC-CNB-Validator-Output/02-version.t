use strict;
use warnings;

use Plack::App::NKC::CNB::Validator::Output;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($Plack::App::NKC::CNB::Validator::Output::VERSION, 0.01, 'Version.');
