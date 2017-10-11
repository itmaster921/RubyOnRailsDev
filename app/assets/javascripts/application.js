// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require tether
//= require jquery_ujs
//= require jquery.remotipart
//= require bootstrap/bootstrap.min.js
//= require jquery/clockpicker
//= require metisMenu/jquery.metisMenu.js
//= require pace/pace.min.js
//= require slimscroll/jquery.slimscroll.min.js
//= require iCheck/icheck.min.js
//= require fullcalendar/moment.min.js
//= require fullcalendar/fullcalendar.min.js
//= require fullcalendar/lang-all.js
//= require fullcalendar/fullcalendar.scheduler.min.js
//= require peity/jquery.peity.min.js
//= require sparkline/jquery.sparkline.min.js
//= require toastr
//= require footable/footable.all.min.js
//= require select2/select2.full.min.js
//= require sweetalert/sweetalert.min.js
//= require flot/jquery.flot.js
//= require flot/jquery.flot.tooltip.min.js
//= require flot/jquery.flot.resize.js
//= require flot/jquery.flot.pie.js
//= require flot/jquery.flot.time.js
//= require flot/jquery.flot.spline.js
//= require sparkline/jquery.sparkline.min.js
//= require validate/jquery.validate.min.js
//= require jvectormap/jquery-jvectormap-2.0.2.min.js
//= require jvectormap/jquery-jvectormap-world-mill-en.js
//= require ladda/spin.min.js
//= require bootstrap-datepicker
//= require ladda/ladda.min.js
//= require jsKnob/jquery.knob.js
//= require admins.js
//= require confirmations.js
//= require courts.js
//= require dashboard.js
//= require dayoff.js
//= require discounts.js
//= require inspinia.js
//= require jquery.leanModal.min.js
//= require jquery.scrollTo.js
//= require memberships.js
//= require pages.js
//= require prices.js
//= require reservation.js
//= require stripe.js
//= require venues.js
//= require emails.js
//= require invoice.js
//= require react
//= require react_ujs
//= require dropzone/react-dropzone.min.js
//= require slick/react-slick.min.js
//= require react_bootstrap
//= require components
//= require i18n
//= require i18n.js
//= require i18n/translations
//= require axios
//= require react-select/index.js
//= require react-select/react-input-autosize.min.js
//= require react-select/react-select.min.js
//= require react-virtualized-select/react-virtualized-select.js
//= require react-onclickoutside/index.js
//= require react-datepicker/react-datepicker.min.js
//= require Chart
//= require fetch/fetch.js

$(function() {
  if ($('.clockpicker').length || $('.date').length)
    initDateTimes();

  if ($('.dial').length)
    initKnobs();
});

function initDateTimes() {
  $('.clockpicker').clockpicker({
    placement: 'bottom',
    align: 'left',
    autoclose: true,
    afterDone: function() {
      start_time = $("#reservationStartTime").val();
      end_time = $("#reservationEndTime").val();
    }
  });

  $('.date').datepicker({
    orientation: "bottom",
    calendarWeeks: true,
    autoclose: true,
    todayHighlight: true,
    format: 'dd/mm/yyyy',
    language: I18n.currentLocale()
  });
}

//sshehata: I am aware of how bad this is.

var laddaObject;
function disableButton($button) {
  return function() {
    if (!$button.attr('ladda')) {
      $button.attr('ladda', 'true');
      laddaObject = Ladda.create($button.get(0));
    }
    laddaObject.start();
  };
}

function enableButton($button) {
  return function() {
    laddaObject.stop();
  };
}

function initKnobs() {
    $('.dial').knob();
}

function object_foreach(object, callback) {
  if (object == null || object == undefined) {
    return false
  }

  Object.keys(object).map(function(key) {
    callback(key, object[key])
  })
}

jQuery.validator.addMethod("validDate", function(value, element) {
    return this.optional(element) || moment(value,"DD/MM/YYYY").isValid();
  },
  I18n.t('validator.errors.date')
);
jQuery.validator.addMethod("validTime", function(value, element) {
    return this.optional(element) || moment(value,"HH:mm").isValid();
  },
  I18n.t('validator.errors.time')
);
