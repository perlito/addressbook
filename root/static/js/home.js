$(function(){
	GetUsers();
});

function GetUsers(page){
	var req = "page=1";
	if ( /^\d+$/.test(page) ){
		req = "page=" + page; 			
	}
	
	
	$.ajax({
				type: "PATCH",
				url: "/user/user",
				data: req,
				dataType: 'json',
				success: function(json){
								var table = "<h3>В базе есть:" +
												json.count +
												" пользователей</h3>" +
												"<a href='#' onclick='OpenAddUser()'>Добавить пользователя</a>" +
												"<table id='user_table'><tr>" + 
												"<th>Имя, Фамилия</th>" + 
												"<th>Адреса</th>" +
												"<th>Почтовые адреса</th>" +
												"<th>Телефоны</th>" +
												"<th>Действие</th>" +
												"</tr>";

								for ( var i in json.users ){
									var user = json.users[i];
									
									var addresses = "";    					
			    					for (var j in user.addresses){
			    						var address = "<div id='address_"+
			    										  j+
			    										  "' class='address' ><a href='#' onclick='GetAddress(" +
			    										  j +
			    										  ")' >"+
			    										  user.addresses[j] +
			    										  "</a>&nbsp;/&nbsp;<a href='#' onclick=\"DelItem("+
														  j+				    										  
			    										  ", 'address')\" >Удалить</a></div>";
			    						addresses += address;				  	    					
			    					}		
			    					
									var phones = "";    					
			    					for (var j in user.phones){
			    						var phone = "<div id='phone_" +
			    										  j +
			    										  "' class='phone'><span>"+
			    										  user.phones[j] +
			    										  "</span>&nbsp;/&nbsp;<a href='#' onclick=\"DelItem("+
														  j+				    										  
			    										  ", 'phone')\" >Удалить</a></div>";
			    						phones += phone;				  	    					
			    					}					    									

									var mails = "";    					
			    					for (var j in user.mails){
			    						var mail = "<div id='mail_" +
			    										  j +
			    										  "' class='mail'><span>"+
			    										  user.mails[j] +
			    										  "</span>&nbsp;/&nbsp;<a href='#' onclick=\"DelItem("+
														  j+				    										  
			    										  ", 'mail')\" >Удалить</a></div>";
			    						mails += mail;				  	    					
			    					}		
									
									var row = "<tr id='user_" + 
												 user.id	+
												 "'><td class='edit_user'>" +	
												 user.firstname +
												 " " +
												 user.lastname + 	 
												 "</td><td>" +
												 addresses +
												 "<a href='#' class='add' onclick='OpenAddItem($(this), \"address\", " +
												 user.id +
												 ")'>Добавить</a>" +
												 "<div class='add_item'></div>"+													 
												 "</td><td>" +
												 mails +	
												 "<a href='#' class='add' onclick='OpenAddItem($(this), \"mail\", " +
												 user.id +
												 ")'>Добавить</a>" +
												 "<div class='add_item'></div>"+													 
												 "</td><td>"+
												 phones +
												 "<a href='#' class='add' onclick='OpenAddItem($(this), \"phone\", " +
												 user.id +
												 ")'>Добавить</a>" +
												 "<div class='add_item'></div>"+													 
												 "</td><td>" +
												 "<a href='#' onclick=OpenEditUser(" +
												 user.id +
												 ")>Изменить</a>&nbsp;<a href='#' onclick=DelUser(" +
												 user.id +
												 ")>Удалить</a>" +
												 "</td></tr>";	
									table += row;			 
								}
								table += "</table><br>"
								if (json.previous_page) {
									var lnk = "<a href='#' onclick=\"GetUsers(" +
												 json.previous_page +
												 ")\" >Следующая страница</a>";	
									table += lnk;			 
								}

								if (json.next_page) {
									var next_page = json.next_page || 0;
									
									var lnk = "<a href='#' onclick=\"GetUsers(" +
												 next_page +												
												 ")\" >Следующая страница</a>";				 
									table += lnk;			 
								}								
								
								$('#main').html(table);
											
						},
				error: function(json){
								$('#main').html("<h3>Пользователей не найдено</h3>");
						}					
			});
}

function DelUser(id){
	if ( /^\d+$/.test(id) ){
		var url = "/user/user/" + id; 
		$.ajax({
					type: "DELETE",
					url: url,
					dataType: "json",
					success: function(json){
								Message(json.message);
								$('tr#user_'+id).remove();
					},
					error: function(json){
								Message("Пользователь не найден");								
					}
			});	
	}	
}

function Message(message, reload){
	$('#error').text(message);
	setTimeout( '$("#error").text("")', 5000 );
	if (reload)	{
		location.reload();	
	}
}

function OpenAddUser(id){
		var form = "<form onsubmit='AddUser();return false' id='add_user_form'>Имя<br><input type=text name=firstname><br><br>" +
					  "Фамилия<br><input type=text name=lastname><br><br>" +
					  "Телефон<br><input type=text name=phone><br><br>" +
					  "Email<br><input type=text name=mail><br><br>" +
					  "Адрес<br><input type=text name=address><br><br>"+
					  "<div id='address_selector'></div>" +
					  "<button>Добавить</button><a href='#' onclick='CloseOpenUser()'>Закрыть</a></form>";	
		$.ajax({
					type: "OPTIONS",
					url: "/user/address",
					dataType: "json",
					success: function(json){
							var select = "Выбрать из адресов<br><select id=address_list onchange='AddressToField()'><option></option>";
							for (var i in json){
								var option = "<option value='" +
												 json[i] +
												 "'>" +
												 json[i] +
												 "</option>";
								select += option;				  										
							}
							select += "</select>";
							
							$('#address_selector').html(select);					
					}		
		});			  		  
		$('#edit_user').html(form);			  
}

function AddressToField() {
	$('#edit_user input[name=address]').val( $('#address_list').val() );	
}


function AddUser(){
	$.ajax({
			type: "PUT",
			url: "/user/user",
			dataType: "json",
			data: $('#add_user_form').serialize(),
			success: function(json){
					Message(json.message, 1);			
			},
			error: function(json){
					Message("error");			
			}	
	});
}

function OpenEditUser(id){
	var url = "/user/user/" + id;	
	
	$.get(url, function(json){
				
				var form = "<form onsubmit='EditUser($(this));return false' id=edit_user_form>"+
				  "<input type=hidden name=id value='" +
				  json.id + 
				  "'>Имя<br><input type=text name=firstname value='" +
				  json.firstname + 
				  "'><br>"+
				  "Фамилия<br><input type=text name=lastname value='" +
				  json.lastname +
				  "'><br><button>Сохранить</button></form>";
				$('tr#user_'+id).find('.edit_user').html(form);  	
		});			  
}

function EditUser(form){
	var url = "/user/user/" + form.find('[name=id]').val();
	$.post(url,
			 form.serialize(),
			 function(json){
			 	$('tr#user_' + json.id).find('.edit_user').text(json.firstname + " " + json.lastname);	
			 },
			 "json"
			);	
}

function GetAddress(id) {
	var url = "/user/address/" + id;
	$.get(url,function(json){
				var users = "";
				for (i in json.users){
					users += json.users[i];
					users += "<br><br>";	
				}		
				var table = "<table><tr>"+
								"<th>Адрес</th>"+
								"<th>Пользователи</th>"+
								"<th>Действие</th>"+
								"</tr><tr>"+
								"<td id='address_field'>"+
								json.address+
								"</td><td>"+
								users +
								"</td><td>"+
								"<a href='#' onclick=OpenEditAddress("+
								json.id+								
								")>Изменить</a>&nbsp;"+
								"<a href='#' onclick='DelAddress("+
								json.id+
								")'>Удалить</a>"+
								"</td>"+
								"</tr></table>"+
								"<a href='/'>На главную</a>";
								
				$('#main').html(table);									
		});
}

function DelAddress(id){
	var url = "/user/address/" + id;
	$.ajax({
				type: "DELETE",
				url: url,
				success: function(){
						location.reload();				
				},
				error: function(json){
						Message("Произошла ошибка пожалуйста повторите");				
				}
				});
}

function OpenEditAddress(id){
	var url = "/user/address/" + id;
	$.get(url,function(json){
				var form = "<form onsubmit='EditItem($(this), \"address\");return false;'>"+
							  "<input type=text name=address value='"+
							  json.address+
							  "'><input type=hidden name=id value="+
							  json.id+
							  "><br><button>Сохранить</button></form>";
				$('#address_field').html(form);			  
		});
}

function EditItem(form, item) {
	var id = form.find('[name=id]').val();
	var url = "/user/"+ item + "/" + id;
	$.post(url, 
			form.serialize(),
			function(json){
					$('#' + item + "_field").text(json.item);		
			 }			
			);
}

function OpenAddItem(el, item, id){
		var form = "<form onsubmit='AddItem($(this), \"" +
					  item +
					  "\");return false;' >"+
					  "<input type=text name='" +
					  item+
					  "'><input type=hidden name=user_id value='" +
					  id +
					  "'><button>Сохранить</button></form>";
		el.parent().find('.add_item').html(form);			  
}

function AddItem(form, item){
	var url = "/user/user/" + item;
	
	$.ajax({
				type: "OPTIONS",
				url: url,
				data: form.serialize(),
				dataType: "json",
				success: function(json){
							var html_id = item + "_" + json.id;
														
							var span = "<div id='"+html_id+ "' class=" + item + "><span>" + json.item + "</span>"; 								
							if (item == "address") {
								span = "<div id='"+html_id +"' class='address'>"+
										 "<a href='#' onclick='GetAddress("+
										 json.id+
										 ")'>"+
										 json.item+
										 "</a>";
							}
							
							var row = 	span+
											"&nbsp;/&nbsp;<a href='#' onclick=\"DelItem("+
											json.id+
											",'"+
											item +
											"')\" >Удалить</а></div>";
							$(row).insertBefore( form.parent().parent().find('a.add').last() );	
							form.parent().html("");				
				},
				error: function(json){
							Message("Произошла ошибка, пожалуйста повторите");
					}				
				});
}

function DelItem(id, item){
		var url = "/user/user/" + item + "/" + id;
		$.ajax({
					type: "HEAD",
					url: url,
					dataType: "json",
					success: function(json){
							Message("Успешно удалено!");
							$('#'+ item + "_" + id).remove();
					},
					error: function(json){
							Message("Произошла ошибка, пожалуйста повторите");
					}						
					});
}

function CloseOpenUser() {
	$('#edit_user').html("");	
}
