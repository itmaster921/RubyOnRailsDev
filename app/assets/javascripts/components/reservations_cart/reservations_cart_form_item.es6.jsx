class ReservationsCartFormItem extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      price: null
    }
  }

  _on_date_change(e) {
    var date = e.target.value
    var start_time = this._r().start.format('HH:mm')
    var end_time = this._r().end.format('HH:mm')
    reservations_cart_store.update_reservation(this._r().key, {
      start: moment(date + ' ' + start_time,  'DD/MM/YYYY HH:mm'),
      end:   moment(date + ' ' + end_time,  'DD/MM/YYYY HH:mm')
    })
  }

  _on_start_time_change(e) {
    var date = this._r().start.format('DD/MM/YYYY')
    var time = e.target.value
    reservations_cart_store.update_reservation(this._r().key, {
      start: moment(date + ' ' + time,  'DD/MM/YYYY HH:mm')
    })
  }

  _on_end_time_change(e) {
    var date = this._r().end.format('DD/MM/YYYY')
    var time = e.target.value
    reservations_cart_store.update_reservation(this._r().key, {
      end: moment(date + ' ' + time,  'DD/MM/YYYY HH:mm')
    })
  }

  _on_court_change(e) {
    reservations_cart_store.update_reservation(this._r().key, { court_id: e.target.value })
  }

  _on_price_change(e) {
    reservations_cart_store.update_reservation(this._r().key, { custom_price: e.target.value })
  }

  _on_price_restore(e) {
    e.preventDefault()
    reservations_cart_store.update_reservation(this._r().key, { custom_price: null })
  }

  _on_item_delete(key) {
    reservations_cart_store.delete_reservation(key)
  }

  _name(field) {
    return "reservations[" + this._r().key + "][" + field + "]"
  }

  _price() {
    return this._r().custom_price == null ? this._r().price : this._r().custom_price
  }

  _r() {
    return this.props.reservation
  }

  _init_clockpicker(element) {
    $(element).clockpicker({
      placement: 'bottom',
      align: 'left',
      autoclose: true,
      afterDone: function() {
        var event = new Event('input', { bubbles: true });
        element.dispatchEvent(event);
      }
    })
  }

  // TODO: add react-datepicker for 'date' field
  render() {
    var r = this.props.reservation
    return(
      <div className="row cart-form-item">
        { this.render_error() }

        <div className="col-xs-3">
          <div className="form-group">
            <input name={ this._name("date") } onChange={this._on_date_change.bind(this)} value={ r.start.format('DD/MM/YYYY') } className="form-control" type="text" readOnly='true'/>
          </div>
        </div>

        <div className="col-xs-2">
          <div className="form-group">
            <input name={ this._name("start_time") } onChange={this._on_start_time_change.bind(this)} value={ r.start.format('HH:mm') } ref={ this._init_clockpicker } className="form-control" type="text" required='true'/>
          </div>
        </div>

        <div className="col-xs-2">
          <div className="form-group">
            <input name={ this._name("end_time") } onChange={this._on_end_time_change.bind(this)} value={ r.end.format('HH:mm') } ref={ this._init_clockpicker } className="form-control" type="text" required='true'/>
          </div>
        </div>

        <div className="col-xs-3">
          <div className="form-group">
            <select name={ this._name("court_id") } onChange={this._on_court_change.bind(this)} value={ r.court_id } className="form-control court-select" required='true'>
              { this.render_courts_options() }
            </select>
          </div>
        </div>

        <div className="col-xs-2">
          <div className="form-group has-feedback">
            <input name={this._name("price")} value={ this._price() } onChange={this._on_price_change.bind(this)} className="form-control" placeholder={ I18n.t('reservations.new.price_placeholder') } type="text" required='true'/>
            { this.render_restore_price_icon() }
          </div>
        </div>

        { this.render_delete() }
      </div>
    )
  }

  render_error() {
    if (this._r().error) {
      return(
        <div className="col-xs-12 cart-booking-error">
          { this._r().error }
        </div>
      )
    }
  }

  render_courts_options() {
    return (
      this.props.courts.map(function(c) {
        return <option value={ c.id } key={ c.id } >{ c.text }</option>
      })
    )
  }

  render_restore_price_icon() {
    if (this._r().custom_price) {
      return(
        <i className="fa fa-undo form-control-feedback restore-cart-price" onClick={ this._on_price_restore.bind(this) }></i>
      )
    }
  }


  render_delete() {
    return(
      <div className="cart-form-item-delete">
        <i className="fa fa-trash" onClick={ this._on_item_delete.bind(this, this._r().key) }></i>
      </div>
    )
  }
}
