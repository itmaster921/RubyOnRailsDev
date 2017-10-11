$(function () {
  var $discountForm = $('#new_discount');
  if ($discountForm.length) {
    initDiscountForm($discountForm, createDiscountSucc, discountFormFail);
  }

  if ($('.del-discount').length)
    initDeleteDiscount();

});

function assignDiscount(elem) {
  var id = $(elem).attr('form');

  if (elem.checked) {
    $('#' + id).submit();
    $($(elem).data('select')).attr('disabled','');
  }
  else {
    $($(elem).data('select')).removeAttr('disabled');
    $('#' + id).submit();
  }
}

function initDiscountSelect() {
  var urls = $('.discount-select').map(function() { return $(this).data('discounts-url') });
  urls = $.unique(urls);

  $.map(urls, function(url) {
    $.getJSON(url).done(function(data) {
      data = $.map(data, function(item) {
        return { id: item.id, text: item.name };
      });
      $('.discount-select[data-discounts-url="' + url + '"]').each(function(index) {
        var $select = $(this);
        $select.html('');
        $select.select2({
          placeholder: 'Select discount.',
          allowClear: false,
          data: data
        });
        var selected = $.grep(data, function(n, i) {
          return n.id == $select.data('value');
        });
        if (selected.length) {
          $select.val($select.data('value')).trigger('change');
          $select.attr('disabled', 'disabled');
          $('input[data-select="#' + $select.get(0).id + '"').get(0).checked = true;
        } else {
          $select.val("").trigger('change');
          $select.removeAttr('disabled');
          $('input[data-select="#' + $select.get(0).id + '"').removeAttr('checked');
        }
      })
    })
  })
}

function initDiscountForm($form, succ, fail) {
  $form.on('ajax:success', succ);
  $form.on('ajax:error', fail);
  $form.on('ajax:beforeSend', disableButton($('.ladda-button')));
  $form.validate();
}

function initDeleteDiscount() {
  $('.del-discount').on('ajax:success', deleteDiscountSucc);
}

function createDiscountSucc(resp, data) {
  var $discountForm = $('#new_discount');
  enableButton($('.ladda-button'))();
  $('#discounts').append($(data));
  initDeleteDiscount();
  initDiscountSelect();
  $('#add-discount').modal('hide');
}

function discountFormFail(resp, data) {
  enableButton($('.ladda-button'))();
  data.responseJSON.forEach(function (value, i) {
    toastr.error(value);
  });
}

function deleteDiscountSucc(resp, data) {
  $('#discount-'+data.id).remove();
  initDiscountSelect();
}

function loadDiscountModal(elem) {
  var url = $(elem).data('discount-url');
  $.ajax({
    url: url,
    success: loadDiscountSucc
  });
  return false;
}

function loadDiscountSucc(resp) {
  $('#edit-discount').replaceWith($(resp));
  initKnobs();
  $('#edit-discount').modal('show');
  initDiscountForm($('.edit_discount'), editDiscountSucc, discountFormFail);
}

function editDiscountSucc(resp, data) {
  var id = $(data).attr('id');
  $('#'+id).replaceWith($(data));
  $('#edit-discount').modal('hide');
  initDeleteDiscount();
  initDiscountSelect();
}
