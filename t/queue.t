use Test;

use Boxee::Queue;

plan tests => 1;

require "t/config.pl";

my $queue = Boxee::Queue->new(username => $boxee_username, password => $boxee_password);
$queue->list();

ok(1, 1);

#$queue->remove(1);

#ok(1, 1);