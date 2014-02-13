use strict;
use warnings;

use addressbook;

my $app = addressbook->apply_default_middlewares(addressbook->psgi_app);
$app;

