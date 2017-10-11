var Modal = ReactBootstrap.Modal;
var Button = ReactBootstrap.Button;

class Price extends React.Component {
  constructor(props) {
    super(props);
    this.WindowEnum = this.props.windowEnum;
    this.state = {
      price: this.props.price,
      showModal: this.props.showModal
    };
  }

  componentWillReceiveProps(nextProps) {
    this.state = {
      price: nextProps.price,
      showModal: nextProps.showModal
    };
  }

  changeWindow() {
    this.props.changeWindow(this.WindowEnum.EDIT);
  }

  handleDelete() {
    var self = this;
    $.ajax({
      url: this.state.price.delete_url,
      type: 'delete',
      success: function(resp) {
        $('tr[data-price=' + resp.id + ']').remove();
        self.props.closeHandler();
      }
    });
  }

  render() {
    return(
      <Modal show={this.state.showModal} onHide={this.props.closeHandler} >
        {this.header()}
        {this.content()}
        {this.footer()}
      </Modal>
    );
  }

  header() {
    return (
      <Modal.Header>
        <Modal.Title>{I18n.t('venues.manage_price.header')} {this.state.price.id}</Modal.Title>
        <p>{ I18n.t('venues.manage_price.notice')}</p>
        <p>
          <span className="pull-right">
            <strong>{I18n.t('venues.manage_price.from')} </strong>
            {this.state.price.start_time}
            <strong> {I18n.t('venues.manage_price.to')} </strong>
            {this.state.price.end_time}
          </span>
          {I18n.t('venues.manage_price.price')} <strong>{this.state.price.value}</strong>
        </p>
      </Modal.Header>
    );
  }

  content() {
    var courts = this.state.price.courts.map(function(court, index) {
      return(
        <li className='list-group-item first-item' key={index}>
          <span className='pull-right' key={index}>
            <span className='label label-primary' key={index}>
              ID: {court.id}
            </span>
          </span>
          {court.court_name} ({court.sport })
        </li>
      );
    });

    days = this.state.price.days.map(function(day, index) {
      return(
        <li key={index}>
        {I18n.t('date.day_names')[day]}
        </li>
      );
    })
    return (
      <Modal.Body>
        <ul className='list-group clear-list'>
          <strong>{I18n.t('venues.manage_price.price_rule')}</strong>
          {courts}
        </ul>
        <strong>{I18n.t('venues.manage_price.days_affect')}</strong>
        <ul>
          {days}
        </ul>
      </Modal.Body>
    );
  }

  footer() {
    var delButton, editButton = null;
    if (this.props.can_manage) {
       delButton = <Button className="btn btn-default" onClick={this.handleDelete.bind(this)}>
                     <i className="fa fa-trash"></i>
                     {I18n.t('venues.manage_price.delete_button')}
                   </Button>;
       editButton = <Button className="btn btn-default" onClick={this.changeWindow.bind(this)}>
                      {I18n.t('venues.manage_price.edit_button')}
                     </Button>;

    }
    return(
       <Modal.Footer>
         {delButton}
         {editButton}
         <Button className="btn btn-default" onClick={this.props.closeHandler}>
           {I18n.t('venues.manage_price.close_button')}
         </Button>
       </Modal.Footer>
    );
  }
}
