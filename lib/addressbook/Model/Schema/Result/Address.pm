use utf8;
package addressbook::Model::Schema::Result::Address;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

addressbook::Model::Schema::Result::Address

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<address>

=cut

__PACKAGE__->table("address");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 address

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "address",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 user_addresses

Type: has_many

Related object: L<addressbook::Model::Schema::Result::UserAddress>

=cut

__PACKAGE__->has_many(
  "user_addresses",
  "addressbook::Model::Schema::Result::UserAddress",
  { "foreign.address_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 users

Type: many_to_many

Composing rels: L</user_addresses> -> user

=cut

__PACKAGE__->many_to_many("users", "user_addresses", "user");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-02-02 16:55:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nmwKDoLG6UI55xTazrTKGw

# Return hash of address's user
sub address_user {
	my $self = shift;

	my %users;
	$users{$_->id} = $_->name for $self->users;
	
	return \%users;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
