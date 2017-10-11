$(function () {
  $('#new_court').on('ajax:success', addCourtSucc);
  $('#new_court').on('ajax:error', addCourtFail);
});

function addCourtSucc(e, data) {
  courtFormSucc("Court Added Successfully!");
  $('tbody#courts').replaceWith($(data));
  $('.modal').modal('hide');
  initCourtSelect();
}

function addCourtFail(e, data) {
  toastr.error('something went wrong!');
}

function loadCourtModal(elem) {
  $.ajax({
    url: $(elem).data('court-url'),
    success: loadCourtSucc
  });
  return false;
}

function loadCourtSucc(resp) {
  $('#court-modal').find('.modal-content').html($(resp));
  $('#court-modal').modal('show');
}

function loadCourtEdit(elem) {
  $.ajax({
    url: $(elem).data('url'),
    success: loadCourtEditSucc
  });
  return false;
}

function loadCourtEditSucc(resp) {
  $('#court-modal').find('.modal-content').html($(resp));
  $('#edit-court').on('ajax:success', updateCourtSucc);
  $('#edit-court').on('ajax:error', updateCourtFail);
  hide_court_sport_name();
  courts_indexes_select_add_form_listeners();
}

function updateCourtSucc(e, data) {
  initCourtSelect();
  courtFormSucc("Court Updated Successfully!", data);
  loadCourtModal($('#cancel-update'));
  $('tr[data-court=' + $(data).data('court') + ']').html($(data).html());
}

function updateCourtFail(e, data) {
  toastr.error('something went wrong!');
}

function courtFormSucc(message, data) {
  swal({
    title: message,
    text: "Thanks!",
    type: "success"
  });
}

function toggleSharedCourtsSelect(){
  if($('#share_courts_checkbox').is(':checked')){
    $("#share_courts_div").show();
    $("#share_courts_div select").attr('disabled', false);
  } else {
    $("#share_courts_div").hide();
    $("#share_courts_div select").attr('disabled', true);
  }
}

function courts_indexes_select_update() {
  var sport_name = $('#court_sport_name').val();
  var indoor = $('input[name="court[indoor]"]:checked').val();
  var copies = $('#new_court input[name=copies]').val();
  var custom_sport_name = $('#court_custom_sport_name').val();

  if (sport_name || custom_sport_name && indoor) {
    //clear outdated select
    $('#court-indexes-select option').remove();
    // load available indexes
    $.ajax({
      url: $('#court-indexes-select').data('url'),
      data: {
        indoor: indoor,
        sport_name: sport_name,
        custom_sport_name: custom_sport_name,
        exept_court: $('#court-indexes-select').data('id'),
        copies: copies },
      success: courts_indexes_select_build
    });
  }
}

function courts_indexes_select_add_form_listeners() {
  $('#court_sport_name, input[name="court[indoor]"]').on('change', function() {
    courts_indexes_select_update();
  });

  $('#new_court input[name=copies], #court_custom_sport_name').on('change', function() {
    courts_indexes_select_update();
  });

  $('#court-indexes-select').on('change', function() {
    $(this).data('selected', $(this).val());
    redraw_court_generated_name();
  });

  courts_indexes_select_update();
  redraw_court_generated_name();
}

function courts_indexes_select_build(indexes) {
  if (!Array.isArray(indexes)) {
    indexes = []
  };

  var data = $.map(indexes, function(index) {
    return { id: index, text: index };
  });

  $('#court-indexes-select').select2({
    data: data
  });

  var selected = Number.parseInt($('#court-indexes-select').data('selected'))

  if (selected && indexes.indexOf(selected) > -1) {
    $('#court-indexes-select').val(selected).trigger('change');
  } else {
    $('#court-indexes-select').val(indexes[0]).trigger('change');
  }
}

function redraw_court_generated_name() {
  var index = $('#court-indexes-select').val();
  if (!index) index = '';

  var type = $('input[name="court[indoor]"]:checked').val();
  var custom_sport_name = $('#court_custom_sport_name').val();
  if (custom_sport_name) type = custom_sport_name;

  $('input[name="court[court_name]"]').val(type + ' ' + index);
}


function deleteCourt(element) {
  swal({
    title: I18n.t('courts.delete.confirm_title'),
    text: I18n.t('courts.delete.confirm_text'),
    type: "warning",
    showCancelButton: true,
    confirmButtonText: I18n.t('courts.delete.button_text')
  },
  function(isConfirmed) {
    if (isConfirmed)
      $.ajax({
        url: $(element).data('delete-url'),
        type: "delete",
        success: deleteSuccess,
        fail: updateCourtFail
      });
  });
  return false;
}

function deleteSuccess(data) {
  $('.modal').modal('hide');
  $('tr[data-court=' + data.id + ']').remove();
  initCourtSelect();
  courtFormSucc(I18n.t('courts.delete.success_text'), data);
}
