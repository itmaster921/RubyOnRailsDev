var Button = ReactBootstrap.Button;
var Checkbox = ReactBootstrap.Checkbox;

class ReservationsCart extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return(
      <div className='reservations-cart'>
        { this.render_grid() }
      </div>
    )
  }

  render_grid() {
    if (this.props.count  > 0 && this.props.use_cart) {
      return(
        <div className='row'>
          <div className='col-xs-6'>
            { this.render_button() }
          </div>
          <div className='col-xs-6'>
            { this.render_checkbox() }
          </div>
        </div>
      )
    } else {
      return(
        <div className='row'>
          <div className='col-xs-12'>
            { this.render_checkbox() }
          </div>
        </div>
      )
    }
  }

  render_checkbox() {
    return(
      <Checkbox checked={ this.props.use_cart } onChange={ this.props.on_use_cart_change.bind(this) }>
        <span className='fa fa-shopping-cart'></span>
        <span>{ I18n.t('venues.view.use_cart') }</span>
      </Checkbox>
    )
  }

  render_button() {
    return(
      <Button className="btn btn-default" onClick={ this.props.on_book_all_click.bind(this) }>
        <span className="btn-name">{ I18n.t('venues.view.book_all') }</span>
        <span className="label label-primary">{ this.props.count }</span>
      </Button>
    )
  }
}
