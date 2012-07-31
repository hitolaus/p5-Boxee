package Boxee::Queue;

$VERSION = "1.00";

use strict;
use LWP;
use XML::Simple;
use MIME::Base64;
use Data::Dumper qw(Dumper);
use Getopt::Long;

# Globals
our $CANNED_RESPONSE; # Mock data for unit testing

# Locals
my $USER_AGENT = "BoxeeQueue/0.1";

# GetOptions(
# 	'u|user=s' => \$username, 
# 	'p|password=s' => \$password,
# 	'r|referral=i' => \$referral);
# 
# 
# my $cmd = $ARGV[0];
# if (!$cmd) {
# 	usage();
# 	exit $ERRNO_PARAM;
# }
# 
# if ($cmd eq "list") {
# 	list_queue($username, $password);
# }
# elsif ($cmd eq "remove") {
# 	if (!$referral) {
# 		usage();
# 		exit $ERRNO_PARAM;
# 	}
# 	remove_queue($referral, $username, $password);
# }


sub new
{
	my($class, %args) = @_;
	
	my $self = bless({}, $class);
	
	if (! exists $args{username})
	{
		die "Mandatory paramter 'username' not defined";
	}
	
	if (! exists $args{password})
	{
		die "Mandatory paramter 'password' not defined";
	}
	
   	$self->{username} = $args{username};
   	$self->{password} = $args{password};
	
	return $self;
}


sub list
{
	my ($self) = @_;
	
	my $res = _request($self, 'http://app.boxee.tv/api/get_queue', 'GET');
	
	my $xml = XMLin($res->{content});
	
	#print Dumper($xml);
	
	my @q = [];
	
	foreach my $e (@{$xml->{message}}) {
		while(my ($key, $value) = each(%{$e->{object}})) {
			if ($value->{url}) {
				#print $e->{referral} . " " . $value->{url}. "\n";
				push(@q, {
					id => $e->{referral},
					title => $value->{name},
					description => $value->{description},
					url => $value->{url},
					thumb => $value->{thumb}
				});
			}
		}
	}
	
	return @q;
}

sub remove
{
	my ($self, $referral) = @_;
	
	
	my $content = '<message type="dequeue" referral="'.$referral.'"></message>';
	
	my $res = _request($self, 'http://app.boxee.tv/action/add', 'POST', $content);
	
	if (!$res->{success}) {
		# Return HTTP status code as error value
		return $res->{status};
	}
	
	return 1;
}

sub add
{
	my ($self, $options) = @_;
	
	my $name  = $options->{name};
	my $url   = $options->{url};
	my $thumb = $options->{thumb};
	
	my $content = '<message type="queue"><object type="stream_video"><name>'.$name.'</name><url>'.$url.'</url><thumb>'.$thumb.'</thumb></object></message>';
	
	my $res = _request($self, 'http://app.boxee.tv/action/add', 'POST', $content);
	
	if (!$res->{success}) {
		# Return HTTP status code as error value
		return $res->{status};
	}
	
	return 1;
}

sub _request
{
	my($self, $url, $method, $content) = @_;
	
	if ($CANNED_RESPONSE) {
		return {
			success => 1,
			status  => 200,
			content => $CANNED_RESPONSE
		};
    }
	
	my $ua = LWP::UserAgent->new;
	$ua->agent($USER_AGENT);
	
	my $encoded = encode_base64($self->{username}.':'.$self->{password});
	
	my $req = HTTP::Request->new($method => $url);
	$req->header(Authorization => "Basic " . $encoded);
	$req->content_type('text/xml');
	
	if ($content) {
		$req->content($content);
	}

	my $res = $ua->request($req);
	
	my $response = {
		success => $res->is_success,
		status  => $res->status_line,
		content => $res->content
	};
	
	return $response;
}

1;

__END__

=head1 NAME

Boxee::Queue - Watch Later queue handling

=head1 SYNOPSIS

  use Boxee::Queue;

  # ...

  my $queue = Boxee::Queue->new(username => '...', password => '...');

  my @my_queue = $queue->list();

=head1 DESCRIPTION

C<Boxee::Queue> is access point to the Watch Later queue and supports listing,
adding and removing queue content.

=head2 METHODS

=over 4

=item list()

Lists the user queue

=item add(hash_ref)

Adds an element to the queue. The input parameters to the method are
name, url and thumb.

=item remove(id)

Removes an element from the queue. The id parameter is the id returned from the
'list' method.

=head1 AUTHOR

Jakob Hilarius, http://syscall.dk

=head1 COPYRIGHT AND LICENSE

Copyright 2012 by Jakob Hilarius, http://syscall.dk

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut