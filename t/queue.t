use Test;

use Boxee::Queue;
use File::Spec;

plan tests => 3;

########################################################
# Setup - Load mock data
########################################################

my $can = File::Spec->catfile("t", "canned", "queue_list.xml");
open FILE, "<$can" or die "Cannot open $can";
my $data = join '', <FILE>;
close FILE;
$Boxee::Queue::CANNED_RESPONSE = $data;

my $queue_api = Boxee::Queue->new(username => 'chucknorris', password => 'Chuck Norris doesnt need a password');

########################################################
# Test 'list'
########################################################

my @q = $queue_api->list();

ok($#q, 17);

########################################################
# Test 'remove'
########################################################

my $status = $queue_api->remove(1);

ok($status, 1);

########################################################
# Test 'add'
########################################################

$status = $queue_api->add({name => 'test', url => 'test', thumb => 'test'});

ok($status, 1);
