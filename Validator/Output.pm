package Plack::App::NKC::CNB::Validator::Output;

use base qw(Plack::Component::Tags::HTML);
use strict;
use warnings;

use Data::MARC::Validator::Report;
use Data::NKC::MARC::Menu;
use DateTime;
use English;
use Error::Pure qw(err);
use List::Util 1.33 qw(none);
use MARC::File::XML;
use MARC::Record;
use MARC::Validator;
use NKC::Id::Utils qw(check_cnb_id);
use Plack::App::NKC::CNB::Validator::Utils qw(add_message);
use Plack::Request;
use Plack::Session;
use Plack::Util::Accessor qw(footer lang version zoom);
use Scalar::Util qw(blessed);
use Tags::HTML::Container;
use Tags::HTML::Footer 0.03;
use Tags::HTML::MARC::Validator::Report;
use Tags::HTML::Messages;
use Tags::HTML::NKC::MARC::Menu;
use Unicode::UTF8 qw(decode_utf8);
use ZOOM;

our $VERSION = 0.02;

sub _cleanup {
	my ($self, $env) = @_;

	$self->{'_tags_container'}->cleanup;
	$self->{'_tags_footer'}->cleanup;
	$self->{'_tags_messages'}->cleanup;
	$self->{'_tags_menu'}->cleanup;
	$self->{'_tags_validator_report'}->cleanup;

	return;
}

sub _css {
	my ($self, $env) = @_;

	$self->{'_tags_container'}->process_css;
	$self->{'_tags_footer'}->process_css;
	$self->{'_tags_messages'}->process_css({
		'error' => 'red',
		'info' => 'green',
	});
	$self->{'_tags_menu'}->process_css;
	$self->{'_tags_validator_report'}->process_css;

	$self->{'css'}->put(
		['s', '#input'],
		['d', 'margin-left', '1em'],
		['e'],

		['s', '#input select'],
		['d', 'margin-bottom', '1em'],
		['e'],
	);

	return;
}

sub _check_required_middleware {
	my ($self, $env) = @_;

	# Check use of Session before this app.
	if (! defined $env->{'psgix.session'}) {
		err 'No Plack::Middleware::Session present.';
	}

	return;
}

sub _lang {
	my ($self, $key) = @_;

	$self->{'_lang'} = {
		'ces' => {
			'page_title' => decode_utf8('ČNB validátor'),
		},
		'eng' => {
			'page_title' => 'CNB validator',
		},
	};

	return $self->{'_lang'}->{$self->lang}->{$key};
}

sub _load_data {
	my ($self, $env) = @_;

	# Zoom connections.
	$self->{'_zoom'} = eval {
		ZOOM::Connection->new(
			$self->{'_zoom_data'}->host,
			$self->{'_zoom_data'}->port,
			'databaseName' => $self->{'_zoom_data'}->db,
		);
	};
	if ($EVAL_ERROR) {
		add_message(
			$self,
			$env,
			'error',
			decode_utf8('Nemůžu se připojit na \''.$self->{'_zoom_data'}->host.'\'.'),
		);
		return;
	}
	$self->{'_zoom'}->option('preferredRecordSyntax' => 'usmarc');

	my $rs;
	if (exists $self->{'_search_id'}->{'cnb'}) {
		$rs = $self->{'_zoom'}->search_pqf('@attr 1=48 '.$self->{'_search_id'}->{'cnb'});
		$self->{'_searching'} = decode_utf8('ČČNB: '.$self->{'_search_id'}->{'cnb'});
	} elsif (exists $self->{'_search_id'}->{'isbn'}) {
		$rs = $self->{'_zoom'}->search_pqf('@attr 1=7 '.$self->{'_search_id'}->{'isbn'});
		$self->{'_searching'} = decode_utf8('ISBN '.$self->{'_search_id'}->{'isbn'});
	} elsif (exists $self->{'_search_id'}->{'issn'}) {
		$rs = $self->{'_zoom'}->search_pqf('@attr 1=8 '.$self->{'_search_id'}->{'issn'});
		$self->{'_searching'} = decode_utf8('ISSN '.$self->{'_search_id'}->{'issn'});
	} elsif (exists $self->{'_search_id'}->{'system_id'}) {
		$rs = $self->{'_zoom'}->search_pqf('@attr 1=1032 '.$self->{'_search_id'}->{'system_id'});
		$self->{'_searching'} = decode_utf8('System id '.$self->{'_search_id'}->{'system_id'});
	} else {
		add_message(
			$self,
			$env,
			'error',
			decode_utf8('Nemůžu najít požadováné dílo.'),
		);
		return;
	}

	# Load data.
	if (defined $rs && $rs->size > 0) {
		my $raw_record = $rs->record(0)->raw;
		$self->{'_marc'} = MARC::Record->new_from_usmarc($raw_record);

		# Update ccnb id if doesn't defined in search.
		if (! defined $self->{'_search_id'}->{'cnb'}) {
			my $ccnb = $self->_subfield('015', 'a');
			if (! $ccnb) {
				$ccnb = $self->_subfield('015', 'z');
			}
			$self->{'_search_id'}->{'cnb'} = $ccnb;
		}
	} else {
		add_message(
			$self,
			$env,
			'error',
			decode_utf8('Nemůžu najít požadováné dílo.'),
		);
		return;
	}

	return;
}

sub _prepare_app {
	my $self = shift;

	# Inherite defaults.
	$self->SUPER::_prepare_app;

	my %p = (
		'css' => $self->css,
		'tags' => $self->tags,
	);
	$self->{'_tags_container'} = Tags::HTML::Container->new(%p,
		'height' => '1%',
		'padding' => '0.5em',
		'vert_align' => 'top',
	);
	$self->{'_tags_footer'} = Tags::HTML::Footer->new(%p);
	$self->{'_tags_messages'} = Tags::HTML::Messages->new(%p,
		'flag_no_messages' => 0,
	);
	$self->{'_tags_menu'} = Tags::HTML::NKC::MARC::Menu->new(%p,
		'mode_search' => 1,
	);
	$self->{'_tags_validator_report'} = Tags::HTML::MARC::Validator::Report->new(%p);

	$self->{'_zoom_data'} = $self->zoom;
	if (! defined $self->{'_zoom_data'}
		|| ! blessed($self->{'_zoom_data'})
		|| ! $self->{'_zoom_data'}->isa('Data::NKC::MARC::Zoom')) {

		err "ZOOM data object must be a 'Data::NKC::MARC::Zoom' instance.";
	}

	return;
}

sub _process_actions {
	my ($self, $env) = @_;

	my $session = Plack::Session->new($env);

	$self->_check_required_middleware($env);

	$self->{'_title'} = $self->_lang('page_title');

	$self->{'_search'} = undef;
	$self->{'_searching'} = undef;
	$self->{'_marc'} = undef;

	$self->_process_form($env);
	$self->_load_data($env);

	my $menu = Data::NKC::MARC::Menu->new(
		'cnb_id' => $self->{'_search_id'}->{'cnb'},
		'logo_image_location' => '/img/logo.png',
		'logo_location' => '/',
		'search' => $self->{'_search'},
		'searching' => $self->{'_searching'},
	);
	$self->{'_tags_menu'}->init($menu);

	# Validate.
	if (defined $self->{'_marc'}) {
		my @plugin_reports;
		foreach my $plugin (MARC::Validator::plugins) {
			my $plugin_obj = $plugin->new(
				'record_id_def' => '015a',
			);
			$plugin_obj->init;
			$plugin_obj->process($self->{'_marc'});
			$plugin_obj->postprocess;

			# Plugin report.
			push @plugin_reports, $plugin_obj->report;
		}

		# Report object.
		my $validation_report = Data::MARC::Validator::Report->new(
			'datetime' => DateTime->now,
			'plugins' => \@plugin_reports,
		);

		$self->{'_tags_validator_report'}->init($validation_report);
	}

	$self->{'_tags_footer'}->init($self->footer);

	return;
}

sub _process_form {
	my ($self, $env) = @_;

	my $req = Plack::Request->new($env);

	# Check form processing.
	if (! $req->parameters->{'search'}) {
		return;
	}

	$self->{'_search'} = $req->parameters->{'search'};
	$self->{'_search_id'} = check_cnb_id($self->{'_search'});

	return;
}

sub _subfield {
	my ($self, $field, $subfield) = @_;

	my $field_value = $self->{'_marc'}->field($field);
	if (! defined $field_value) {
		return;
	}

	return $field_value->subfield($subfield);
}

sub _tags_middle {
	my ($self, $env) = @_;

	# Process messages.
	my $messages_ar = [];
	my $error = 0;
	if (exists $env->{'psgix.session'}) {
		my $session = Plack::Session->new($env);
		$messages_ar = $session->get('messages');
		foreach my $message (@{$messages_ar}) {
			if ($message->type eq 'error') {
				$error = 1;
				last;
			}
		}
		$session->set('messages', []);
	}
	$self->{'_tags_menu'}->process;
	$self->{'_tags_container'}->process(
		sub {
			$self->{'_tags_messages'}->process($messages_ar);
		},
	);

	if ($error) {
		return;
	}

	# Main.
	$self->{'tags'}->put(
		['b', 'div'],
		['a', 'id', 'main'],
	);
	$self->{'_tags_validator_report'}->process;
	$self->{'tags'}->put(
		['e', 'div'],
	);

	# Footer.
	$self->{'_tags_footer'}->process;

	return;
}

1;

__END__
