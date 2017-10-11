$(function () {
  if ($("#court").length) {
    initDateTimes();
    initHolidayCourtSelect();
    $("#is-venue-checkbox").change(function() {
      if (this.checked) {
        $('#court').prop('disabled', 'disabled');
      } else {
        $('#court').prop('disabled', false);
      }
    });
    $(".delete-offday").on("ajax:success", function (e, data) {
      $('#offday-' + data.id).remove();
    });
    $("#offday-form").on("ajax:success", function (e, data) {
      swal({
        title: "Dayoff added successfully!",
        type: "success"
      });
    });
  }
});

function initHolidayCourtSelect() {
  $.getJSON('/venues/' + $('#court').data('venue-id') + '/courts.json').done(
    function( data ) {

      data = $.map(data, function(item) {
        return { id: item.id, text: item.title_with_sport };
      });

      $('#court').select2({
        placeholder: 'Select Court',
        allowClear: true,
        minimumInputLength: 0,
        data: data
      });
    }
  ).error(function() {
    console.log('error: couldnt get courts!');
  });
}
