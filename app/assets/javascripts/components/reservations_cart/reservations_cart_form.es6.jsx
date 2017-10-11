class ReservationsCartForm extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      reservations: [],
      courts: []
    }
  }

  fetch_data() {
    this.setState({
      reservations: reservations_cart_store.reservations(),
      courts: reservations_cart_store.courts()
    })
  }

  componentDidMount() {
    this.fetch_data()
    reservations_cart_store.add_listener('form', this.fetch_data.bind(this))
  }

  componentWillUnmount() {
    reservations_cart_store.remove_listener('form')
  }

  render() {
    return(
      <div id="reservations-cart-form-items" className="col-xs-12">
        { this.render_heading() }
        { this.state.reservations.map(function(r) {
            return <ReservationsCartFormItem reservation={ r } courts={ this.state.courts } key={ r.key } />
          }.bind(this))
        }
      </div>
    )
  }

  render_heading() {
    return(
      <div className="row">
        <div className="col-xs-3">
          <div className="form-group">
            <label>{ I18n.t('reservations.new.select_date_label') }</label>
          </div>
        </div>

        <div className="col-xs-2">
          <div className="form-group">
            <label>{ I18n.t('reservations.new.start_time_label')}</label><br/>
          </div>
        </div>

        <div className="col-xs-2">
          <div className="form-group">
            <label>{ I18n.t('reservations.new.end_time_label')}</label><br/>
          </div>
        </div>

        <div className="col-xs-3">
          <div className="form-group">
            <label >{ I18n.t('reservations.new.court_label')}</label>
          </div>
        </div>

        <div className="col-xs-2">
          <div className="form-group  has-feedback">
            <label className="control-label">{ I18n.t('reservations.new.price_label') }</label>
            <i className="fa fa-eur form-control-feedback"></i>
          </div>
        </div>
      </div>
    )
  }
}
