package addressbook::Controller::User;
use Moose;
use namespace::autoclean;
use utf8;

BEGIN { extends 'Catalyst::Controller::REST'; }

##########################
# 		Users CRUD			#
######################## 

sub user : Local : ActionClass('REST') { }

sub user_GET :Args(1) {
	my ( $self, $c, $id ) = @_;
	
	return $self->status_bad_request($c, message => "Параметр id должен быть цифрой" ) if $id =~ /\D/;
		
	my $user = $c->model('DB::User')->find( { id => $id } );
	
	return $self->status_not_found( $c, message => "Пользователь с id:$id не найден"	) unless $user;

	$self->status_ok(
							$c,
							entity => {
											firstname => $user->firstname,
											lastname => $user->lastname,
											id => $user->id,									
											}
						);			
}

# Create 
sub user_PUT {
	my ( $self, $c ) = @_;
	
	my ( $firstname, $lastname, $error ) = $self->check_fields($c);
	return $self->status_bad_request( $c, message => $self->check_fields($c) ) if $error;
	
	my $user = $c->model('DB::User')->create({
															firstname => $firstname,
															lastname => $lastname,
															});
															

	my $mail = 	$c->request->params->{mail} || $c->req->data->{mail};						 
	$user->create_related('mails', 
									{ mail => $mail } 
								) if ( $mail =~ /[\w\.\-]+?\@[a-z\-]+?\.[a-z]{2,3}/ );
	
	my $phone = $c->request->params->{phone} || $c->req->data->{phone};							
	$user->create_related('phones', 
									{ phone => $phone } 
								) if $phone ;
	
	my $address = $c->request->params->{address} || $c->req->data->{address};
	
	if ( $address ){
		my $addr = $c->model('DB::Address')->find( { address => $address } );
		
		$addr = $c->model('DB::Address')->create( { address => $address } ) unless $addr;
		
		$user->create_related('user_addresses',
									 { address_id => $addr->id } 
									 ); 
	}							 													
	$self->status_ok(
							$c,
							entity => { message => "Новый пользователь успешно создан" },
							);													
}


# Update
sub user_POST :Args(1) {
	my ( $self, $c, $id ) = @_;
		
	return $self->status_bad_request($c, message => "Parameter id must be a number" ) if $id =~ /\D/;	
	
	my ( $fistname, $lastname, $error ) = $self->check_fields($c);
	return $self->status_bad_request( $c, message => $self->check_fields($c) ) if $error;
	
	my $user = $c->model('DB::User')->find( { id => $id } );
	
	return $self->status_not_found($c, message => "Пользователь с id:$id не найден") unless $user;	
	
	$user->firstname( $fistname );
	$user->lastname( $lastname );
	
	$user->update;
	
	$self->status_ok(
							$c,
							entity => { 
											id        => $user->id,
											firstname => $user->firstname,
											lastname  => $user->lastname,
											 },
							);		

}


sub user_DELETE {
	my ( $self, $c, $id ) = @_;

	return $self->status_bad_request($c, message => "Parameter id must be a number" ) unless $id =~ /^\d+$/;		
	
	my $user = $c->model('DB::User')->find( { id => $id } );
	
	return $self->status_not_found($c, message => "User with id:$id not found") unless $user;
	
	$user->delete;

	$self->status_ok(
							$c,
							entity => { message => "Пользователь с id:$id удален!" },
							);			
	
}


# Get 10 users
sub user_PATCH {
	my ( $self, $c ) = @_;
	
	my $page = $c->request->params->{page} || "";
	$page = 1 unless $page =~ /^\d+$/;
		
	my $word = $c->request->params->{word} || "";
		
	my $result = $c->model('DB::User')->search( {} );
	
	$result = $result->page($page);
	$result->pager;
	
	my %users;
	while( my $user = $result->next){
			my $id = $user->id;
									
			$users{$id}{id} = $id;
			$users{$id}{firstname} = $user->firstname;
			$users{$id}{lastname} = $user->lastname;
			$users{$id}{addresses} = $user->user_address;
			$users{$id}{mails} = $user->user_mails;
			$users{$id}{phones} = $user->user_phones;
	}

	if ( scalar(keys %users) ) {
		
		$self->status_ok(
						  $c,
						  entity => {
						  					next_page => $result->pager->next_page,
						  					previous_page => $result->pager->previous_page,	
						  					count => $result->pager->total_entries,
						  					users => \%users,
						  				}												
						);	
	}
	else {
		$self->status_not_found(
										$c,
										message => "Can't find any users",
										);	
	}				
}

# Add phone, mail or address 
sub user_OPTIONS :Args(1){
	my ( $self, $c, $item ) = @_;
	
	return $self->status_bad_request( $c, message => "Нет опции $item" ) 
			 unless $item =~ /^mail$|^phone$|^address$/;
			 
	my $user_id = $c->request->params->{user_id} || $c->req->data->{user_id};
	
	my $value = $c->request->params->{$item} || $c->req->data->{$item};
	
	my $table = ucfirst($item);
	
	my %data = ($item => $value);
	$data{user_id} = $user_id if $item ne "address";

	my $created = $c->model("DB::$table")->create( \%data );
	
	$created->create_related("user_addresses", { user_id => $user_id } ) if $item eq "address";
	
	$self->status_ok(
							$c,
							entity => { 
											$item => $created->$item,
											id => $created->id,
											item => $created->$item, 												
										  },
							); 
		
}

sub user_HEAD :Args(2){
	my ( $self, $c, $item, $id ) = @_;
	
	return $self->status_bad_request( $c, message => 'Не правильные данные $id, $input' ) 
			if ( $id !~ /^\d+$/ || $item !~ /^mail$|^phone$|^address$/ );
	
	my $table = ucfirst($item);
	my $finded = $c->model("DB::$table")->find( { id => $id } );
	
	return $self->status_not_found( $c, message => "$item с id:$id не найден") unless $finded;
	
	$finded->delete;
	
	return $self->status_ok($c, entity => {});			
}

# Check input fields for create and update methods
sub check_fields {
	my ( $self, $c ) = @_;
	
	my $error;
	my $firstname = $c->request->params->{firstname} || $c->req->data->{firstname} || "";
	my $lastname = $c->request->params->{lastname} || $c->req->data->{lastname} || "";
	$error = "Empty firstname" unless $firstname;
	$error = "Empty lastname" unless $lastname;
	
	return ( $firstname, $lastname, $error );  
}

##########################
# 		Address CRUD		#
######################## 

sub address :Local :ActionClass('REST') { }

# Get address and users in that address
sub address_GET :Args(1){
	my ( $self, $c, $id ) = @_;
	
	my $address = $c->model('DB::Address')->find( { id => $id } ) if $id =~ /^\d+$/;
	
	return $self->status_not_found( $c, message => "Адрес с id:$id не найден" ) unless $address;
	
	$self->status_ok(
							$c,
							entity => { 
											id => $address->id,
											address => $address->address,
											users => $address->address_user,												
											}							
							);
	
}

# Get maximum 100 addreses, for help in create new user
sub address_OPTIONS {
	my ( $self, $c ) = @_;
	
	my $result = [ $c->model('DB::Address')->search(undef, { rows => 100 } ) ];
	
	return $self->status_not_found($c, message => "Адресов не найдено") unless scalar(@$result);	
	
	my %address;
	$address{ $_->id } = $_->address for @$result;
	
	$self->status_ok(
					  $c,
					  entity => \%address,								
					);		
	 				
}

sub address_POST {
	my ( $self, $c, $id ) = @_;
	
	my $address = $c->model('DB::Address')->find( { id => $id } ) if $id =~ /^\d+$/;
	
	return $self->status_not_found( $c, message => "Адрес с id:$id не найден" ) unless $address;
	
	my $req_address = $c->request->params->{address} || $c->req->{address};
	
	$address->address($req_address) if $req_address;
	$address->update;
	
	$self->status_ok(
							$c,
							entity => {
											address => $address->address,
											id	=> $address->id,
											item => $address->address,
											},
							);
}

sub address_DELETE {
	my ( $self, $c, $id ) = @_;
		
	my $address = $c->model('DB::Address')->find( { id => $id } ) if $id =~ /^\d+$/;
	
	return $self->status_not_found( $c, message => "Адрес с id:$id не найден" ) unless $address;
	
	$address->delete;
	
	$self->status_ok( 
							$c,
							entity => { message => "Адресс id:$id удален!" }				
						 );
}

=encoding utf8

=head1 AUTHOR

tigran,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->config(
	'default' => 'application/json',
	'stash_key' => 'rest',
	'map'       => {
	   'text/html'          => 'JSON::XS',# For debugging in browser
	   'text/xml'           => 'XML::Simple',
	   'text/x-yaml'        => 'YAML',
	   'application/json'   => 'JSON::XS',
	   'text/x-json'        => 'JSON::XS',
	   'text/x-data-dumper' => [ 'Data::Serializer', 'Data::Dumper' ],
	   'text/x-data-denter' => [ 'Data::Serializer', 'Data::Denter' ],
	   'text/x-data-taxi'   => [ 'Data::Serializer', 'Data::Taxi'   ],
	   'application/x-storable'   => [ 'Data::Serializer', 'Storable' ],
	   'application/x-freezethaw' => [ 'Data::Serializer', 'FreezeThaw' ],
	   'text/x-config-general'    => [ 'Data::Serializer', 'Config::General' ],
	   'text/x-php-serialization' => [ 'Data::Serializer', 'PHP::Serialization' ],
	},
);

__PACKAGE__->meta->make_immutable;

1;
