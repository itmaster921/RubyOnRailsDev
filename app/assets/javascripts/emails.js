function createEmailList(){
  var name = $('input[name="email_list_name"]').val()
  var venue_id = $('#email-lists').data('venue');

  $.ajax({
    url: '/venues/'+venue_id+'/email_lists',
    method: "POST",
    data: {
      email_list: { name: name }
    },
    dataType: "json",
    success: handleEmailListCreated,
    error: emailListError
  });
}

function handleEmailListCreated(resp){
  $('input[name="email_list_name"]').val("");
  var email_list = resp.email_list;
  toastr.success(resp.message);
  $('.tabs-left .nav-tabs li.active').removeClass('active');
  var li = '<li class="active">';
  li += '<a data-toggle="tab" style="margin-right: -2px;" onclick="loadEmailListTab(this)" data-email-list='+email_list.id+' href="#tab-'+email_list.id+'">'+email_list.name+'</a>';
  li += '</li>';
  $('.tabs-left ul.nav-tabs').append(li);
  loadEmailListTab($('.tabs-left .nav-tabs li.active a'));
}

function loadEmailLists(element) {
  var url = $(element).data('url');
  $.get(url, function(resp){
    $("#email-lists-tab").html(resp);
    loadEmailListTab($('.tabs-left .nav-tabs li.active a'));
  });
}

function loadEmailListTab(element){
  var tab = $(element);
//  if(tab.hasClass('active')) return;

  var email_list_id = tab.data('email-list');
  var venue = $('#email-lists').data('venue');
  var email_list = tab.data('email-list');
  var url = '/venues/' + venue + '/email_lists/' + email_list;
  $.get(url, function(resp){
    var div = '<div id="tab-' + email_list_id + '" classs="tab-pane active">';
    div += resp;
    div += '</div>';
    tab.closest('.tabs-container').find('.tab-content').html(div);
    $("#tab-" + email_list_id).tab('show');
  });
}

function handleUserSelected(element){
  var remove_count = $(element).closest(".email-list").find("input:checkbox[name='users-del[]']:checked").length;
  var remove_users_btn = $("button[name=remove-users]:visible")[0];
  if(remove_count > 0){
    remove_users_btn.removeAttribute("disabled");
  } else {
    remove_users_btn.setAttribute("disabled", true);
  }
}

function confirmRemoveUsers(btn){
  var modal = $("#confirm-modal");
  var checked_array = $(btn).closest(".email-list").find("input:checkbox[name='users-del[]']:checked");
  var remove_count = checked_array.length;
  var users = checked_array.map(function(i, checkbox){
    return checkbox.value;
  }).toArray();

  modal.find(".modal-title").text('Confirm');
  var body_text = 'Remove ' + remove_count + ' users from the email list?';
  modal.find(".modal-body").html(body_text);
  modal.find("#confirm-btn")[0].setAttribute('onclick', 'removeUsers(['+ users.toString() + '])');
  modal.modal('show');
}

function removeUsers(users){
  var venue = $("input[name='venue_id']").val();
  var email_list = $("input[name='email_list_id']").val();
  var url = '/venues/' + venue + '/email_lists/' + email_list + '/remove_users';

  $.ajax({
    url: url,
    method: "POST",
    dataType: "json",
    data: {
      users: users
    },
    success: function(resp){
      toastr.success(resp.message);
      $("#confirm-modal").on('hidden.bs.modal', function(e){
        loadEmailListTab($('.tabs-left .nav-tabs li.active a'));
      });
      $("#confirm-modal").modal('hide');
    },
    error: emailListError
  });
}

function showAddUsersModal(element){
  $.ajax({
    url: $(element).data('url'),
    method: "GET",
    dataType: "json",
    success: populateAddUsersTable,
    error: emailListError
  });
}

function populateAddUsersTable(users){
  var modal = $("#add-users-modal");
  var table = modal.find("table");
  var tbody = table.find('tbody');
  tbody.html("");
  users.forEach(function(user, i){
    var tr = '<tr>';
    tr += '<td>' + user.first_name + ' ' + user.last_name + '</td>';
    tr += '<td>' + user.email + '</td>';
    tr += '<td><input type="checkbox" name="users-add[]" value=' + user.id + '></td>';
    tr += '</tr>';

    tbody.append(tr);
  });

  modal.modal('show');
  table.footable({'useParentWidth': true});
}

function addUsersToEmailList(element){
  var modal = $("#add-users-modal");
  var checked_array = modal.find("input:checkbox[name='users-add[]']:checked");
  var users = checked_array.map(function(i, checkbox){
    return checkbox.value;
  }).toArray();
  sendAddUsersToEmailListRequest(users);
}

function sendAddUsersToEmailListRequest(users){
  var venue = $("input[name='venue_id']").val();
  var email_list = $("input[name='email_list_id']").val();
  $.ajax({
    url: '/venues/' + venue + '/email_lists/' + email_list + '/add_users',
    method: "POST",
    dataType: "json",
    data: {
      users: users
    },
    success: function(resp){
      toastr.success(resp.message);
      $("#add-users-modal").on('hidden.bs.modal', function(e){
        loadEmailListTab($('.tabs-left .nav-tabs li.active a'));
      });
      $("#confirm-modal").modal('hide');
    },
    error: emailListError
  });

}

function renameList(){
  var modal = $("#confirm-modal");
  modal.find(".modal-title").text('Rename List');

  var input_field = '<input type="text" name="email_list_name" class="form-control">';
  modal.find(".modal-body").html(input_field);
  modal.find("#confirm-btn")[0].setAttribute('onclick', 'sendRenameListReq(this)');
  modal.on('shown.bs.modal', function () {
    $('input[name="email_list_name"]').focus();
  })
  modal.modal('show');
}

function sendRenameListReq(element){
  var name = $(element).closest('.modal-content').find('input[name="email_list_name"]').val();
  var venue_id = $("input[name='venue_id']").val();
  var email_list_id = $("input[name='email_list_id']").val();

  $.ajax({
    url: '/venues/' + venue_id + '/email_lists/' + email_list_id,
    method: "PUT",
    dataType: "json",
    data: {
      email_list: { name: name }
    },
    success: handleListRenamed,
    error: emailListError
  });
}

function handleListRenamed(resp){
  var email_list = resp.email_list;
  toastr.success(resp.message);
  $("#confirm-modal").on('hidden.bs.modal', function(e){
    $('.tabs-left .nav-tabs li.active a').text(email_list.name).click();
  });
  $("#confirm-modal").modal('hide');
}

function confirmDeleteEmailList(element){
  var modal = $("#confirm-modal");
  modal.find(".modal-title").text('Confirm');
  var name = $(element).data('name');
  var body_text = 'Delete Email list: ' + name + '?'
  modal.find(".modal-body").html(body_text);
  modal.find("#confirm-btn")[0].setAttribute('onclick', 'deleteEmailList()');
  modal.modal('show');
}

function deleteEmailList(){
  var venue_id = $("input[name='venue_id']").val();
  var email_list_id = $("input[name='email_list_id']").val();
  $.ajax({
    url: '/venues/' + venue_id +'/email_lists/' + email_list_id,
    method: "DELETE",
    dataType: "json",
    success: handleListDeleted,
    error: emailListError
  });
}

function handleListDeleted(resp){
  toastr.success(resp.message);
  $("#confirm-modal").on('hidden.bs.modal', function(e){
    var deleted_li = $('.tabs-left .nav-tabs li.active');
    deleted_li.remove();
    $('.tabs-left .nav-tabs li:first a').click();
  });
  $("#confirm-modal").modal('hide');
}

function emailListError(jqxhr, textStatus, error){
  if(jqxhr.responseJSON){
    toastr.error(jqxhr.responseJSON.errors);
  } else {
    toastr.error(jqxhr.statusText);
  }
}

function initSendEmailTab(element){
  $.ajax({
    url: "/venues/" + $(element).data('venue') + "/email_lists.json",
    method: 'GET',
    dataType: 'json',
    success: function(email_lists){
      $('#email_to_groups').select2({
        placeholder: 'Select Recipients',
        allowClear: true,
        minimumInputLength: 0,
        multiple: true,
        data: $.map(email_lists, function(item) {
          return { id: item.id, text: item.name };
        })
      });
    },
    error: emailListError
  });
}

function setEmailFromField(){
  var selected = $('#email_from_select').val();
  var email_from_text = $('#email_from_text');
  if(selected == 'other'){
    email_from_text.fadeIn().removeClass('hidden');
    email_from_text.attr('disabled', false);
  } else {
    email_from_text.fadeOut().addClass('hidden');
    email_from_text.attr('disabled', true);
  }
}

function submitCustomMailForm(event){
  event.preventDefault();
  var mail = validateCustomMailForm();
  if(!mail) return;
  var fd = new FormData();
  fd.append('custom_mail', JSON.stringify(mail));
  if($('#header_image').val()){
    fd.append('header_image', $('#header_image')[0].files[0]);
  }
  fd.append('venue_id', $('#venue_id').val());

  $.ajax({
    url: '/custom_mail.js',
    method: "POST",
    dataType: "json",
    data: fd,
    processData: false,
    contentType: false,
    cache: false,
    success: function(resp){
      toastr.success(resp.message);
      document.getElementById('custom-mail-form').reset();
      setEmailFromField();
      $("#email_to_groups").select2().val(null).trigger("change");
    },
    error: emailListError
  });

  return false;
}

function validateCustomMailForm(mail){
  var mail = {};
  mail.send_copy = $('#send_copy').is(':checked');
  mail.to_groups = $('#email_to_groups').val();
  mail.to_users = $('#email_to_users').val().trim();

  if($('#email_from_text').attr('disabled')){
    mail.from = $('#email_from_select').val();
  } else {
    mail.from = $('#email_from_text').val();
  }

  if(!(mail.subject = $('#email_subject').val().trim())){
    toastr.error("Email subject field is empty")
    return false;
  } else if(!(mail.body = $('#email_body').val().trim())){
    toastr.error("Email body field is empty")
    return false;
  } else if(!(mail.to_groups || mail.to_users)){
    toastr.error("Email recipients field is empty")
    return false;
  } else if(!(mail.from)){
    toastr.error("Email From field is empty")
    return false;
  }
  return mail;
}
