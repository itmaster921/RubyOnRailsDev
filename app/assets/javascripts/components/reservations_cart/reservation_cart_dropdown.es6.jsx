class ReservationsCartDropdown extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      reservations: [],
      courts: {},
      open: false
    }
  }

  _by_id(courts) {
    var by_id = {}
    courts.forEach(function(c) {
      by_id[c.id] = c.text
    })
    return by_id
  }

  fetch_data() {
    this.setState({
      reservations: reservations_cart_store.reservations(),
      courts: this._by_id(reservations_cart_store.courts())
    })
    if (this.state.reservations.length == 0) {
      this.setState({ open: false })
    }
  }

  componentDidMount() {
    this.fetch_data()
    reservations_cart_store.add_listener('dropdown', this.fetch_data.bind(this))
    $('body')[0].addEventListener('click', this.handleDocumentClick.bind(this))
  }

  componentWillUnmount() {
    reservations_cart_store.remove_listener('dropdown')
    $('body')[0].removeEventListener('click', this.handleDocumentClick.bind(this))
  }

  /* click outside */
  handleDocumentClick(evt) {
    const area = ReactDOM.findDOMNode(this.refs.area);

    if (!area.contains(evt.target)) {
      this.setState({ open: false })
    }
  }

  _toggle_dropdown() {
    this.setState({ open: !this.state.open })
  }

  _on_item_delete(key, e) {
    reservations_cart_store.delete_reservation(key)
  }

  _on_cart_clear() {
    reservations_cart_store.empty_cart()
    this._toggle_dropdown()
  }

  _on_reserve_all() {
    reservations_cart_store.booking_form()
    this._toggle_dropdown()
  }

  render() {
    return(
      <div id='reservations-cart-dropdown' ref='area' className={ this.state.open ? 'open' : '' } >
        { this.render_link() }
        { this.render_menu() }
      </div>
    )
  }

  render_link() {
    return(
      <a className="dropdown-toggle count-info" onClick={ this._toggle_dropdown.bind(this)} href="#">
        <i className="fa fa-shopping-cart"></i>
        <span className="label label-primary">{ this.state.reservations.length }</span>
      </a>
    )
  }

  render_menu() {
    if (this.state.reservations.length > 0) {
      return(
        <ul className="dropdown-menu dropdown-alerts">
          { this.state.reservations.map(function(r) {
              return [this.render_item(r), <li className="divider" key={ 'divider' + r.key }></li> ]
            }.bind(this))
          }
          { this.render_actions() }
        </ul>
      )
    }
  }

  render_item(r) {
    return(
      <li className="cart-dropdown-item">
        <div className="row" key={ r.key } >
          <div className="col-xs-7">
            <span>
              { this.state.courts[r.court_id] }, { r.start.format('DD/MM/YY') }
            </span>
          </div>

          <div className="col-xs-5 text-right">
            <span>
              { r.start.format('HH:mm') } - { r.end.format('HH:mm') }
            </span>
          </div>

          { this.render_delete(r) }
        </div>
      </li>
    )
  }

  render_delete(r) {
    return(
      <div className="cart-dropdown-item-delete">
        <i className="fa fa-trash" onClick={ this._on_item_delete.bind(this, r.key) }></i>
      </div>
    )
  }

  render_actions() {
    return(
      <div className="cart-dropdown-actions text-center">
        <span onClick={ this._on_cart_clear.bind(this) } >
          { I18n.t('venues.view.clear') } <i className="fa fa-trash"></i>
        </span>
        <span onClick={ this._on_reserve_all.bind(this) }>
          { I18n.t('venues.view.reserve_all') } <i className="fa fa-angle-right"></i>
        </span>
      </div>
    )
  }
}
