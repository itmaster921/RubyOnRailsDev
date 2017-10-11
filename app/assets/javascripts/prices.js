$(function () {
  if ($('.remote-del-btn.price').length)
    initPriceDel();
  $('#new_price_form').on('ajax:success', addPriceSucc);
  $('#new_price_form').on('ajax:error', addPriceFail);
});

function addPriceSucc(e, data) {
  swal({
    title: "Price added successfully",
    text: "Thanks!",
    type: "success"
  });
  $('tbody#prices').append($(data));
  initPriceDel();
  $('.modal').modal('hide');
}

function addPriceFail(e, data) {
  toastr.error('something went wrong!');
  $('.modal').modal('hide');
  $('#modalPriceConflict').html($(data.responseText)).modal('show');
}

function initPriceDel() {
  var $delPrices = $('.remote-del-btn.price');
  $delPrices.on('ajax:success', function (e, data) {
    $('.modal').modal('hide');
    $('tr[data-price=' + data.id + ']').remove();
  });
}

function loadPriceModal(elem) {
  $.ajax({
    url: $(elem).data('price-url'),
    success: loadPriceSucc
  });
  return false;
}

function loadPriceSucc(resp) {
  $('#price-modal').find('.modal-content').html($(resp));
  initPriceDel();
  $('#price-modal').modal('show');
}

function initCourtSelect() {
  jQuery.getJSON('/venues/' + $('#e1').attr('data-venue-id') + '/courts.json').done(
    function( data ) {

      data = $.map(data, function(item) {
        return { id: item.id, text: item.title_with_sport };
      });

      $('#e1').html('');
      jQuery('#e1').select2({
        placeholder: 'Select Courts',
        allowClear: true,
        minimumInputLength: 0,
        multiple: true,
        data: data
      });
    }
  );
}
