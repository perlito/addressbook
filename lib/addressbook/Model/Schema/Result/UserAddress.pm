use utf8;
package addressbook::Model::Schema::Result::UserAddress;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

addressbook::Model::Schema::Result::UserAddress

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

=head1 TABLE: C<user_address>

=cut

__PACKAGE__->table("user_address");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=head2 address_id

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "user_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "address_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</user_id>

=item * L</address_id>

=back

=cut

__PACKAGE__->set_primary_key("user_id", "address_id");

=head1 RELATIONS

=head2 address

Type: belongs_to

Related object: L<addressbook::Model::Schema::Result::Address>

=cut

__PACKAGE__->belongs_to(
  "address",
  "addressbook::Model::Schema::Result::Address",
  { id => "address_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 user

Type: belongs_to

Related object: L<addressbook::Model::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "addressbook::Model::Schema::Result::User",
  { id => "user_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-02-02 16:55:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SXWLF+ZZXY+vmZRB/qEy7g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
