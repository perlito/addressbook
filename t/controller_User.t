use strict;
use warnings;
use Test::More;


use Catalyst::Test 'addressbook';
use addressbook::Controller::User;

ok( request('/user')->is_success, 'Request should succeed' );
done_testing();
