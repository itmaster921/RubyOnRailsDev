class ReservationsCartStore {
  constructor(venue_id) {
    this.listeners = {}
    this.state = {
      reservations: {},
      courts: [],
      use_cart: false,
      last_key: 0
    }
    this.venue = venue_id
    this.user  = null
    this._fetch_courts()
  }

  // accessors

  use_cart(use = null) {
    if (use !== null) {
      this._setState({ use_cart: use })
    }
    return this.state.use_cart
  }

  reservations() {
    return Object.keys(this.state.reservations).map(function(key) {
      return this.state.reservations[key]
    }.bind(this))
  }

  courts() {
    return this.state.courts
  }

  user_id() {
    return this.user
  }

  // actions|reducers

  add_listener(name, listener) {
    this.listeners[name] = listener
  }

  remove_listener(name) {
    this.listeners[name] = null
    delete this.listeners[name]
  }

  add_reservation(data) {
    var reservations = this.state.reservations;
    var key = this.state.last_key + 1
    data['key'] = key
    reservations[key] = data
    this._setState({ reservations: reservations, last_key: key })
    this._fetch_price(reservations[key])
    return reservations[key]
  }

  update_reservation(key, data) {
    var data = this._update_reservation(key, data)
    this._fetch_price(data)
    return data
  }

  delete_reservation(key) {
    var reservations = this.state.reservations;
    reservations[key] = null
    delete reservations[key]
    this._setState({ reservations: reservations })
    // in the new fullcalendar version we will be able to rerender only cart events
    $('#calendar').fullCalendar('refetchEvents');
    return true
  }

  empty_cart() {
    this._setState({ reservations: {}, last_key: 0 })
    // in the new fullcalendar version we will be able to rerender only cart events
    $('#calendar').fullCalendar('refetchEvents');
    return true
  }

  booking_form() {
    load_cart_booking_form()
  }

  refetch_prices(user_id) {
    this.user = user_id
    this.reservations().forEach( function(data) {
      this._fetch_price(data)
    }.bind(this))
  }

  // internal

  _call_listeners() {
    Object.keys(this.listeners).map(function(name) {
      this.listeners[name]()
    }.bind(this))
  }

  _setState(data) {
    this.state = Object.assign(this.state, data);
    this._call_listeners()
    return this.state
  }

  _update_reservation(key, data) {
    var reservations = this.state.reservations;
    if (reservations[key]) {
      reservations[key] = Object.assign(reservations[key], data);
      this._setState({ reservations: reservations })
    }
    return reservations[key]
  }

  _fetch_price(data) {
    $.getJSON({
      url: "/venues/" + this.venue + "/court_price_at.json",
      data: {
        start_time: data.start.format('YYYY-MM-DD HH:mm'),
        end_time: data.end.format('YYYY-MM-DD HH:mm'),
        court_id: data.court_id,
        user_id:  this.user,
      },
      success: function(object) {
        if (object.price) {
          this._update_reservation(data.key, { price: object.price })
        }
      }.bind(this)
    })
  }

  _fetch_courts() {
    if (!this.venue) {
      return false;
    }
    $.getJSON('/venues/' + this.venue + '/courts.json').done(
      function( data ) {
        data = $.map(data, function(item) {
          return { id: item.id, text: item.title_with_sport }
        })

        this._setState({ courts: data })
      }.bind(this)
    )
  }
}
