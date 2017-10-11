$(function() {
  if ($('#new_admin').length)
    initAdminForm($('#new_admin'), addAdminSucc, adminFormFail);

  if ($('.del-admin').length)
    initDeleteAdmin();

});

function initAdminForm($form, succ, fail) {
    //$form.find('select').select2();
    $form.validate();
    $form.on('ajax:success', succ);
    $form.on('ajax:error', fail);
    $form.on('ajax:beforeSend', disableButton($('.ladda-button')));
}

function loadAdminModal(elem) {
  var url = $(elem).data('admin-url');
  $.ajax({
    url: url,
    success: loadAdminSucc
  });
  return false;
}

function loadAdminSucc(resp) {
  $('#edit-admin').replaceWith($(resp));
  $('#edit-admin').modal('show');
  initAdminForm($('.edit_admin'), editAdminSucc, adminFormFail);
}

function editAdminSucc(resp, data) {
  enableButton($('.ladda-button'))();
  var id = $(data).attr('id');
  $('#' + id).replaceWith($(data));
  initDeleteAdmin();
  $('#edit-admin').modal('hide');
}

function adminFormFail(resp, data) {
  if (!data.responseJSON)
    return editAdminSucc(resp, data.responseText);
  enableButton($('.ladda-button'))();
  data.responseJSON.forEach(function (value, i) {
    toastr.error(value);
  });
}

function addAdminSucc(resp, data) {
  enableButton($('.ladda-button'))();
  $('#admins').append($(data));
  $('#add-admin').modal('hide');
  initDeleteAdmin();
}

function initDeleteAdmin() {
  $('.del-admin').on('ajax:success', deleteAdminSucc);
  $('.del-admin').on('ajax:error', function(resp, data) {
    data.responseJSON.forEach(function (value, i) {
      toastr.error(value);
    });
  });
}

function deleteAdminSucc(resp, data) {
  $('#admin-'+data.id).remove();
}
