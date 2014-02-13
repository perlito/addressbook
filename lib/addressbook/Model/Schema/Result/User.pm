use utf8;
package addressbook::Model::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

addressbook::Model::Schema::Result::User

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

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 firstname

  data_type: 'text'
  is_nullable: 1

=head2 lastname

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "firstname",
  { data_type => "text", is_nullable => 1 },
  "lastname",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 mails

Type: has_many

Related object: L<addressbook::Model::Schema::Result::Mail>

=cut

__PACKAGE__->has_many(
  "mails",
  "addressbook::Model::Schema::Result::Mail",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 phones

Type: has_many

Related object: L<addressbook::Model::Schema::Result::Phone>

=cut

__PACKAGE__->has_many(
  "phones",
  "addressbook::Model::Schema::Result::Phone",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_addresses

Type: has_many

Related object: L<addressbook::Model::Schema::Result::UserAddress>

=cut

__PACKAGE__->has_many(
  "user_addresses",
  "addressbook::Model::Schema::Result::UserAddress",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 addresses

Type: many_to_many

Composing rels: L</user_addresses> -> address

=cut

__PACKAGE__->many_to_many("addresses", "user_addresses", "address");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-02-02 16:55:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:P36LYTMH83Q6CQ475QKnSg

sub name {
	my $self = shift;
	return $self->firstname . " " . $self->lastname;
}

# Return hash of user's mails
sub user_mails {
	my $self = shift;
	
	my %mails;
	$mails{$_->id} = $_->mail for $self->mails;
	
	return \%mails;
}

# Return hash of user's phones
sub user_phones {
	my $self = shift;
	
	my %phones;
	$phones{$_->id} = $_->phone for $self->phones;
	
	return \%phones;
}

# Return hash of user's addreses
sub user_address {
	my $self = shift;

	my %addresses;
	$addresses{$_->id} = $_->address for $self->addresses;
	
	return \%addresses;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
