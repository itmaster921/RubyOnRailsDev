$(function() {
  if ($('#user-pane').length)
    showPane($('div[data-target="#user-select"]'));
  if ($('#memberships-errors').length)
    $('#memberships-errors').modal('show');
});

function initUserInfo() {
  $('#user-info').hide();
}

function showPane(elem) {
  var pane = $(elem).data('target');
  $('#user-pane').children().hide();
  $('#user-pane').find('.form-control').attr('disabled', 'disabled');
  $(pane).show();
  $(pane).find('.form-control').removeAttr("disabled");
}
