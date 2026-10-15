use strict;
use warnings;

use Test::More 'tests' => 3;
use Test::NoWarnings;

BEGIN {

	# Test.
	use_ok('Plack::App::NKC::CNB::Validator::Utils');
}

# Test.
require_ok('Plack::App::NKC::CNB::Validator::Utils');
