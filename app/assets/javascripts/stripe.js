$(function () {
  $stripeBtn = $(".strp-btn");
  if ($stripeBtn.length) {
    var handler = StripeCheckout.configure({
      key: $stripeBtn.data('stripe-key'),
      locale: $stripeBtn.data('stripe-locale'),
      name: 'Playven',
      token: sendStripeToken,
      panelLabel: 'Add card',
      email: window.currentUserEmail,
      allowRememberMe: false
    });
    $stripeBtn.on('click', function(e) {
      e.preventDefault();
      handler.open({
        description: "Add new card"
      });
    });
  }

  $('#cardSelect').select2();
});

function sendStripeToken(token) {
  $.ajax({
    url: $(".strp-btn").data("user-url"),
    method: "post",
    data: {
      stripeToken: token.id
    },
    success: addCardSucc
  });
	var spinner = $('#pay-spinner');
	spinner.show();
}

function addCardSucc(resp) {
  $('#card-select-div').html($(resp));
  $('#cardSelect').select2();
  if ($('#makeReservationBtn').length)
    $('#makeReservationBtn').removeAttr('disabled');
  alert('Card added successfully');
  $('#pay-spinner').hide();
}

// change 1
// change 2
