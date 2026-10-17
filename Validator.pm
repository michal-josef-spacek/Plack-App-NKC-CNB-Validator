package Plack::App::NKC::CNB::Validator;

use base qw(Plack::Component);
use strict;
use warnings;

use CPAN::Changes::Utils qw(construct_copyright_years);
use Data::HTML::Footer 0.02;
use Plack::App::CPAN::Changes 0.03;
use Plack::App::NKC::CNB::Validator::Output;
use Plack::App::Search 0.04;
use Plack::App::URLMap;
use Plack::Session;
use Plack::Util::Accessor qw(changes css images lang tags zoom);
use Unicode::UTF8 qw(decode_utf8);

our $VERSION = 0.01;

sub call {
	my ($self, $env) = @_;

	my $session = Plack::Session->new($env);

	# Main application.
	return $self->{'_urlmap'}->to_app->($env);
}

sub prepare_app {
	my $self = shift;

	my %p = (
		'css' => $self->css,
		'lang' => 'ces',
		'tags' => $self->tags,
	);

	my ($version, $copyright_years);
	if (defined $self->changes) {
		$version = ($self->changes->releases)[-1]->version;
		$copyright_years = construct_copyright_years($self->changes);
	}

	my $changes_url = '/changes';
	my $footer = Data::HTML::Footer->new(
		'author' => decode_utf8('Michal Josef Špaček'),
		'author_url' => 'https://skim.cz',
		defined $copyright_years ? (
			'copyright_years' => $copyright_years,
		) : (),
		'height' => '40px',
		defined $version ? (
			'version' => $version,
		) : (),
		defined $self->changes ? (
			'version_url' => $changes_url,
		) : (),
	);
	my %common_params = (
		%p,
		'footer' => $footer,
		defined $version ? (
			'version' => $version,
		) : (),
	);

	my $app_search = Plack::App::Search->new(
		%p,
		'image_height' => '10em',
		'image_link' => $self->images->{'logo'},
		'image_radius' => '15px',
		'search_placeholder' => decode_utf8('ČČNB, ISBN, ISSN, sys. id'),
		'search_url' => '/output',
	)->to_app;
	my $app_output = Plack::App::NKC::CNB::Validator::Output->new(
		%common_params,
		'zoom' => $self->zoom,
	)->to_app;
	my $app_changes;
	if (defined $self->changes) {
		$app_changes = Plack::App::CPAN::Changes->new(
			%p,
			'changes' => $self->changes,
		)->to_app;
	}

	$self->{'_urlmap'} = Plack::App::URLMap->new;
	$self->{'_urlmap'}->map('/' => $app_search);
	$self->{'_urlmap'}->map('/output' => $app_output);
	if (defined $self->changes) {
		$self->{'_urlmap'}->map($changes_url => $app_changes);
	}

	return;
}
1;

__END__
