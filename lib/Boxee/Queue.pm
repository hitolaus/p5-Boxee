package Boxee::Queue;

$VERSION = "1.00";

use strict;
use LWP;
use XML::Simple;
use MIME::Base64;
use Data::Dumper qw(Dumper);
use Getopt::Long;

my $USER_AGENT = "BoxeeQueue/0.1";

my $ERRNO_PARAM = 127;
my $ERRNO_COMM  = 126;

my $username;
my $password;
my $referral;

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
	
	my $username = exists $args{username} ? $args{username} : "";
	my $password = exists $args{password} ? $args{password} : "";
	
   	$self->{username} = $username;
   	$self->{password} = $password;
	
	return $self;
}


sub list
{
	my ($self) = @_;

	my $ua = LWP::UserAgent->new;
	$ua->agent($USER_AGENT);
	
	my $encoded = encode_base64($self->{username}.':'.$self->{password});
	
	my $req = HTTP::Request->new(GET => 'http://app.boxee.tv/api/get_queue');
	$req->header(Authorization => "Basic " . $encoded);
	
	my $res = $ua->request($req);
	
	
	if (!$res->is_success) {
		print "Failure " . $res->status_line, "\n";
		exit $ERRNO_COMM;
	}
	
	my $xml = XMLin($res->content);
	
	#print Dumper($xml);
	
	foreach my $e (@{$xml->{message}}) {
		while(my ($key, $value) = each(%{$e->{object}})) {
			if ($value->{url}) {
				print $e->{referral} . " " . $value->{url}. "\n";
			}
		}
	}
}

sub remove
{
	my ($self, $referral) = @_;
	
	my $ua = LWP::UserAgent->new;
	$ua->agent($USER_AGENT);
	
	my $encoded = encode_base64($self->{username}.':'.$self->{password});
	
	my $req = HTTP::Request->new(POST => 'http://app.boxee.tv/action/add');
	$req->header(Authorization => "Basic " . $encoded);
	$req->content_type('text/xml');
	
	$req->content('<message type="dequeue" referral="'.$referral.'"></message>');

	my $res = $ua->request($req);
	
	if (!$res->is_success) {
		print "Failure " . $res->status_line, "\n";
		exit 127;
	}
}

#add
#http://app.boxee.tv/action/add 
#<message type=\"queue\"><object type=\"stream_video\"><name>Comedy</name><url>smb://10.0.0.32/Media/Series/Comedy.m3u</url><thumb>http://udvikl.es/boxee/watchlater/Comedy.png</thumb></object></message>"
#"Content-Type: "


1;

__END__

# TODO: perldoc here