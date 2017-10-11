function sports_image(type) {
  var  images  = {
    'padel': "icons/select2/padel.png",
    'tennis': "icons/select2/tennis.svg"
    };
}


function searchAvailable(id, date, time, duration, timeToSelect, sport_name) {
  var url = "/venues/" + id + "/available";
  var data = {
    'id': id,
    'date': date,
    'time': time,
    'duration': duration,
    'sport_name': sport_name
  };
  var userId = $('#userId').val();
  $(".venue-category__select").val(data.sport_name);
  if (userId) { data.userId = userId; }
  $('#available_times').html('<div class="modal-booking__contents-one modal-booking__contents-one-first js-accordion_content "><div class="sk-circle"> <div class="sk-circle1 sk-child"></div> <div class="sk-circle2 sk-child"></div> <div class="sk-circle3 sk-child"></div> <div class="sk-circle4 sk-child"></div> <div class="sk-circle5 sk-child"></div> <div class="sk-circle6 sk-child"></div> <div class="sk-circle7 sk-child"></div> <div class="sk-circle8 sk-child"></div> <div class="sk-circle9 sk-child"></div> <div class="sk-circle10 sk-child"></div> <div class="sk-circle11 sk-child"></div> <div class="sk-circle12 sk-child"></div> </div></div>');
  $.ajax({
    type: "POST",
    url: url,
    data: data,
    success: function(success) {
      $('#available_times').html(success);
      if (timeToSelect) {
        $('.js-accordion_link[data-time="'+timeToSelect+'"]').click();
      }
      // try to adjust the prices
      $('.modal-booking__footer .modal-booking__courts .modal-booking__court').each(function() {
        var $court = $(this);
        var id = $court.data('id');
        var time = $court.data('time');
        var $span = $court.find('.hex-price__val');
        var currentPrice = $span.text();
        var $match = $('.modal-booking__contents '+
            '.modal-booking__contents-one[data-time="'+time+'"] '+
            '.modal-booking__court[data-id='+id+']');
        if ($match.length) {
          var matchPrice = $match.find('.hex-price__val').text();
          if (matchPrice != currentPrice) {
            $span.fadeOut(function() {
              $span.text(matchPrice).fadeIn();
            });
          }
        }
      });
      $('.modal-booking__list').scrollTo($('.js-accordion_link.active'));
    }
  });
}

$(document).on('click', '#searchAvailableBtn', function(e){
  e.preventDefault();

  var id = $('#venueId').val();
  var date = $('#searchDate').val();
  var time = $('#searchTime').val();
  var duration = $('#searchDuration option:selected').val();
  var sport_name = $('#searchSport option:selected').val();

  // TODO: maybe date format change will be needed
  $('#booking-modal .js-datepicker__booking').val(date);
  $('#booking-modal .js-timepicker').val(time);
  if ($('#selectUser').val() > 0) {
    var userId = $('#selectUser').val();
  } else {
    var userId = undefined;
  }
  searchAvailable(id, date, time, duration, userId, sport_name);
  mixpanel.track(
      "Search Made",
      {"search_timestamp": Math.floor(Date.now() / 1000)}
  );
});

$(document).on('click', '#searchAvailableMultiBtn', function(e){
  e.preventDefault();

  var id = $(this).data("venue");
  var date = $('#searchDate').val();
  var time = $('#searchTime').val();
  var timeToSelect = $(this).data('time');
  var duration = $('#searchDuration option:selected').val();
  var venueName = $(this).data('venue-name');
  var sport_name = $('#searchSport option:selected').val();
  $('#venueId').val(id);

  // TODO: maybe date format change will be needed
  $('.modal-booking__title').text(venueName);
  $('#booking-modal .js-datepicker__booking').val(date);
  $('#booking-modal .js-timepicker').val(time);
  searchAvailable(id, date, time, duration, timeToSelect, sport_name);
  mixpanel.track(
      "Search Made",
      {"search_timestamp": Math.floor(Date.now() / 1000)}
  );
});

function onModalDateChange() {
  var id = $('#venueId').val();
  var date = $('#booking-modal .js-datepicker__booking').val();
  var time = $('#booking-modal .js-timepicker').val();
  var duration = $('#searchDuration option:selected').val();
  var sport_name = $('.venue-category__select').val();
  if ($('#selectUser').val() > 0) {
    var userId = $('#selectUser').val();
  } else {
    var userId = undefined;
  }
  searchAvailable(id, date, time, duration, userId, sport_name);
}
$(document).ready(function() {
  $('#booking-modal .js-datepicker__booking').on('change', onModalDateChange);
  $('#booking-modal .js-timepicker').on('change', onModalDateChange);

  if($('#pay-spinner'))
    $('#pay-spinner').hide();
});

$(document).on('click', '#searchAvailableVenuesBtn', function(e){
  e.preventDefault();

  var url = "/search";

  var data = {
      'date': $('#searchDate').val(),
      'time': $('#searchTime').val(),
      'duration': $( "#searchDuration option:selected" ).val(),
      'sport_name': $("#searchSport option:selected").val()
    };

  mixpanel.track(
      "Search Made",
      {"search_timestamp": Math.floor(Date.now() / 1000)}
  );

  window.location.href = '/search?' + $.param(data);
});

$(document).on('click', '#showLoginModal', function(e){
  $('#booking-modal')
  .modal('hide')
  .on('hidden.bs.modal', function (e) {
  $('#oops-modal').modal('show');
    $(this).off('hidden.bs.modal');
  });
});

$(document).on('click', '#selectBookingsBtn', function(e){
  if (window.selectedBookings.length == 0)  { selectBookFirst(); return false; }
  $('#booking-modal')
  .on('hidden.bs.modal', function (e) {
  $('#payment-modal .js-courts-number').text(window.selectedBookings.length);

  var paymentSkippable = window.selectedBookings.reduce(function(prev, current) {
    return prev && current.payment_skippable;
  });
  if (window.selectedBookings.length == 1)
    paymentSkippable = window.selectedBookings[0].payment_skippable;
  if (paymentSkippable)
    $('#makeReservationUnpaid').show();
  else
    $('#makeReservationUnpaid').hide();

  showBookingsSummary();
  $('#payment-modal').modal('show');
  $(this).off('hidden.bs.modal');
  })
  .modal('hide');
});

// fetch free passes from api and show payable price
// list bookings and show available game passes
// show resulting price
function showBookingsSummary() {
  var venue_id = $('#venueId').val();
  var user_id = $('#selectBookingsBtn').data('user-id');
  var $summary = $('#payment-modal .js-courts-summary');
  $summary.html('');

  window.selectedBookings.forEach(function(booking, index) {
    var $summary_item = $('#payment-modal .js-courts-summary-item-template .js-courts-summary-item').clone();
    $summary_item.data('index', index);
    $summary_item.find('.js-summary-item-name').text('' + booking.title + ' ' + booking.time);
    $summary_item.find('.js-summary-item-price').text('€' + booking.price);

    $.getJSON('/api/game_passes/available.json',
      {
        venue_id: venue_id,
        user_id: user_id,
        court_id: booking.id,
        start_time: booking.datetime,
        duration: booking.duration,
      }
    ).done(function(data) {
      data = $.map(data, function(item) {
        return { id: item.value, text: item.label };
      });

      if(data.length > 0) {
        $summary_item.find('.js-summary-item-game-pass select').select2({
          placeholder: I18n.t('reservations.edit.select_game_pass'),
          allowClear: true,
          minimumInputLength: 0,
          data: data
        }).on('change', function (evt) {
          window.selectedBookings[index].game_pass_id = evt.target.value
          showTotalPrice();
        }).val(booking.game_pass_id);
      } else {
        $summary_item.find('.js-summary-item-game-pass').addClass('hidden');
      }
    });

    $summary.append($summary_item);
  });

  showTotalPrice();
}

function showTotalPrice() {
  var saved_price_text = '';
  if (calculateSavedPrice() > 0) {
    saved_price_text = '. ' + I18n.t('shared.payment_modal.payment_saved') +
                       ' €' + calculateSavedPrice();
  }
  $('#payment-modal .js-courts-price').text('€' + calculatePayablePrice() + saved_price_text);

  if (calculatePayablePrice() == 0) {
    $('#payment-modal .card-select-row').addClass('hidden');
    $('#payment-modal #makeReservationBtn').text(I18n.t('shared.payment_modal.book_button'));
  } else {
    $('#payment-modal .card-select-row').removeClass('hidden');
    $('#payment-modal #makeReservationBtn').text(I18n.t('shared.payment_modal.pay_button'));
  }
}

function calculatePayablePrice() {
  var payablePrice = 0.0;

  for(var i = 0; i < window.selectedBookings.length; ++i) {
    if (!window.selectedBookings[i].game_pass_id) {
      payablePrice += (+window.selectedBookings[i].price);
    }
  };

  return payablePrice;
}

function calculateSavedPrice() {
  var savedPrice = 0.0;

  for(var i = 0; i < window.selectedBookings.length; ++i) {
    if (window.selectedBookings[i].game_pass_id) {
      savedPrice += (+window.selectedBookings[i].price);
    }
  };

  return savedPrice;
}

$('.modal_payment').on('shown.bs.modal', function (e) {
  $('body').addClass('modal-open');
});
$('.modal_payment').on('hidden.bs.modal', function (e) {
  $('body').removeClass('modal-open');
});

$(document).on('click', '#makeReservationBtn', function(e){
  e.preventDefault();

  var venue_id = $('#venueId').val();
  var url = "/venues/" + venue_id + "/make_reservation";

  var btn = $(this);
  var spinner = $('#pay-spinner');
  btn.attr('disabled', '');
  spinner.show();

  $.ajax({
    type: "POST",
    url: url,
    data: {bookings: window.selectedBookings, card: $('#cardSelect').val()},
    success: function(resp, data) {
      reservationSuccess();
    },
    error: function(jqxhr, status, error) {
      btn.removeAttr('disabled', '');
      spinner.hide();
      reservationFail(jqxhr);
    }
  });
});


$(document).on('click', '#makeReservationUnpaid', function(e){
  e.preventDefault();

  var venue_id = $('#venueId').val();
  var url = "/venues/" + venue_id + "/make_unpaid_reservation";

  var btn = $('#makeReservationBtn');
  var spinner = $('#pay-spinner');
  btn.attr('disabled', '');
  spinner.show();
  $.ajax({
    type: "POST",
    url: url,
    data: {bookings: window.selectedBookings},
    success: function(success) {
      btn.removeAttr('disabled', '');
      spinner.hide();
      $('#payment-modal').modal('hide');
      $('.modal_booking-successful').modal('show');
      window.selectedBookings = [];
      window.renderSelectedBookings();
    },
    error: function(jqxhr, status, error) {
      btn.removeAttr('disabled', '');
      spinner.hide();
      reservationFail(jqxhr);
    }
  });
});

function reservationSuccess(resp, data) {
  var btn = $('#makeReservationBtn');
  var spinner = $('#pay-spinner');
  btn.removeAttr('disabled', '');
  spinner.hide();
  $('#payment-modal').modal('hide');
  $('.modal_booking-successful').modal('show');
  window.selectedBookings = [];
  window.renderSelectedBookings();
}

function reservationFail(resp) {
  switch(resp.status) {
    case 401:
      makeResvUnauth();
      break;
    case 422:
      toastr.error(I18n.t('shared.booking_success_modal.booking_failed'));
      resp.responseJSON.forEach(function (value, i) {
        toastr.error(value);
      });
      break;
  }
}

function selectBookFirst() {
  var swalOptions = {
    title: "Oops..!",
    text: "You have to select some bookings first",
    type: "error",
    allowOutsideClick: true,
    showCancelButton: true,
    confirmButtonText: "OK",
  };
  swal(swalOptions);
  return false;
}

function makeResvUnauth() {
  var swalOptions = {
    title: "Oops..!",
    text: "You have to logged in to make a reservation.",
    type: "error",
    allowOutsideClick: true,
    showCancelButton: true,
    confirmButtonText: "Take me to login",
    cancelButtonText: "Just forget it"
  };
  swal(swalOptions, function() {
    window.location = "/login";
  });
}


$(document).on('click', '.reserveBtn', function(e){
  e.preventDefault();

  $('.availableCourts').slideUp();

  var available = $(this).parent().find('.availableCourts');
  available.slideDown();
});

var creditCard;
$(function () {
  $crdtsel = $('.credit-card');
  if ($crdtsel.length) {
    $crdtsel.change(function () {
      // TODO dirty hack but necessary. remove multiple modals
      creditCard = $(this).val();
    });
  }
});

$(document).ready(function() {
  window.selectedBookings = [];
  window.renderSelectedBookings = function() {
    var html = "";
    for(var i = 0; i < window.selectedBookings.length; ++i) {
      var data = selectedBookings[i];
      html += '<div class="modal-booking__court" data-id="'+data.id+'" data-payment-skippable="' + data.payment_skippable + '" data-time="'+data.time+'"><div class="modal-booking__court-cross"></div><div class="modal-booking__court-title">'+data.title+'</div><div class="modal-booking__court-des">'+data.time+' · '+data.des+'</div><div class="hex-price hex-price_white hex-price_sm"><sup class="hex-price__currency">$</sup><span class="hex-price__val">'+data.price+'</span></div></div>';
    }
    Booking.bar.html(html);
  };

  var Booking = {
    bar: $('.modal-booking__footer .modal-booking__courts'),
    sel: function(el){
      var $this = $(el);
      var data = {
        title:$this.find('.modal-booking__court-title').text(),
        time:$this.parent().parent().attr('data-time'),
        datetime:$this.parent().parent().attr('data-datetime'),
        des:$this.find('.modal-booking__court-des').text(),
        duration:$this.find('.modal-booking__court-duration').text(),
        price:$this.find('.hex-price__val').text(),
        payment_skippable: $this.data('payment-skippable'),
        id:$this.data('id')
      };

      // return if already exists
      for(var i = 0; i < window.selectedBookings.length; ++i) {
        var booking = window.selectedBookings[i];
        if(booking.id == data.id && booking.datetime == data.datetime ) {
          return;
        }
      }

      window.selectedBookings.push(data);
      window.renderSelectedBookings();
    },
    del: function(el){
      var $el = $(el).parent();
      var id = $el.data('id');
      // updating selectedBookings array
      var newBookings = [];
      for(var i = 0; i < window.selectedBookings.length; ++i) {
        var booking = window.selectedBookings[i];
        if (booking.id != id) {
          newBookings.push(booking);
        }
      }
      window.selectedBookings = newBookings;
      // hiding element
      $el.animate({'opacity':0},200,function(){
        this.remove();
      });
    }
  };

  $(document).on('click', '.modal-booking__court-cross', function () {
    Booking.del(this);
  });

  $(document).on('click', '.modal-booking__contents-one .modal-booking__court', function () {
    Booking.sel(this);
  });

  $(document).on('click', '.js-save-selected-bookings', function () {
    if (window.selectedBookings.length > 0) {
      window.localStorage.setItem('selectedBookings', JSON.stringify(window.selectedBookings));
      window.localStorage.setItem('selectedBookingsPath', window.location.pathname + window.location.search);
      window.localStorage.setItem('selectedBookingDate', $('.js-datepicker__booking').val());
      window.localStorage.setItem('selectedBookingTime', $('.js-timepicker__booking').val());
      window.localStorage.setItem('selectedBookingDuration', $('.select2_duration').val());
    }
  });

  if (window.userLoggedIn) {
    var bookingsJson = window.localStorage.getItem('selectedBookings');
    var bookingPath = window.localStorage.getItem('selectedBookingsPath');
    if (bookingsJson) {
      if (bookingPath == window.location.pathname + window.location.search) {
        window.selectedBookings = JSON.parse(bookingsJson);
        window.renderSelectedBookings();
        var date = window.localStorage.getItem('selectedBookingDate');
        $('#searchDate').val(date);
        var time = window.localStorage.getItem('selectedBookingTime');
        $('#searchTime').val(time);
        var duration = window.localStorage.getItem('selectedBookingDuration');
        $('.select2_duration').val(duration);
        // show modal
        if ( $('#searchAvailableBtn').length ) {
          $('#searchAvailableBtn').click();
        } else  {
          $('#searchAvailableMultiBtn').click();
        }
        setTimeout(function() { $('.js-datepicker__booking').val(date); }, 1000);

        // getting rid of localstorage saved vars
        window.localStorage.removeItem('selectedBookings');
        window.localStorage.removeItem('selectedBookingsPath');
        window.localStorage.removeItem('selectedBookingDate');
        window.localStorage.removeItem('selectedBookingTime');
        window.localStorage.removeItem('selectedBookingDuration');
      } else {
        // redirecting user back to page
        window.location.href = bookingPath;
      }
    }
  }
});
