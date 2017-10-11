class ReservationsCartContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      reservations: {},
      use_cart: false
    }
  }

  fetch_data() {
    this.setState({
      reservations: reservations_cart_store.reservations(),
      use_cart: reservations_cart_store.use_cart()
    })
  }

  componentDidMount() {
    this.fetch_data()
    reservations_cart_store.add_listener('cart_switcher', this.fetch_data.bind(this))
  }

  componentWillUnmount() {
    reservations_cart_store.remove_listener('cart_switcher')
  }

  _book_all() {
    reservations_cart_store.booking_form()
  }

  _on_use_cart_change() {
    reservations_cart_store.use_cart(!this.state.use_cart)
  }

  render() {
    return <ReservationsCart
              count={ Object.keys(this.state.reservations).length }
              use_cart= { this.state.use_cart }
              on_use_cart_change= { this._on_use_cart_change.bind(this) }
              on_book_all_click= { this._book_all.bind(this) }
              />
  }
}
