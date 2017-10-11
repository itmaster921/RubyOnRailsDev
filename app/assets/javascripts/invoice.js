$(function() {
  $(document).on('click', '#add-custom-invoice-component', function() {
    var add_button = $(this)
    var $form = $('#custom-invoice-component-form-container form').clone();
    $form.prop('action', add_button.data('url'));

    add_button.closest('td').append($form);
    add_button.addClass('hidden');

    $form.find('.cancel-btn-JS').on('click', function(e) {
      e.preventDefault();
      add_button.removeClass('hidden');
      $form.remove();
    });

    $form.validate();

    $form.on("ajax:success", custom_invoice_component_create_success($form, add_button));
    $form.on("ajax:error", custom_invoice_component_create_fail($form));
  });
});

function custom_invoice_component_create_success(form, button) {
  return function(resp, data) {
    swal({
      title: I18n.t('invoices.drafts_table.custom_component_created'),
      text: I18n.t('thanks'),
      type: "success"
    });

    var row = $('<tr id="custom_invoice_component_' + data.component.id + '">' +
                  '<td colspan="3">' + data.component.name + '</td>' +
                  '<td>' + data.component.vat + '</td>' +
                  '<td>' + data.component.price + '</td>' +
                  '<td>' + data.component.delete_link + '</td>' +
                '</tr>'
    )


    $('<tr><td>' + data.component.name + '</td></tr>');

    row.insertBefore(form.closest('tr'));

    $('#invoice_' + data.invoice_id + '_total').text(data.invoice_total);
    button.removeClass('hidden');
    form.remove();
  }
}

function custom_invoice_component_create_fail(form) {
  return function(resp, data) {
    data.responseJSON.map(function(error) {
      toastr.error(error);
    });

    $.rails.enableFormElements(form.closest('#add-custom-invoice-component'));
  }
}
