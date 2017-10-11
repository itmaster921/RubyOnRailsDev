var Row = ReactBootstrap.Row;
var Col = ReactBootstrap.Col;
var FormControl = ReactBootstrap.FormControl;
var ControlLabel = ReactBootstrap.ControlLabel;
var FormGroup = ReactBootstrap.FormGroup;

class CustomersModal extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      show: false,
      id: null,
      first_name: '',
      last_name: '',
      email: '',
      phone_number: '',
      city: '',
      street_address: '',
      zipcode: '',
    }
  }

  open(data = null) {
    this.setState({show: true});

    if (data && data.id) {
      this.setState({
        id: data.id,
        first_name: data.first_name,
        last_name: data.last_name,
        email: data.email,
        phone_number: data.phone_number,
        city: data.city,
        street_address: data.street_address,
        zipcode: data.zipcode,
      });
    }
  }

  hideModal() {
    this.setState({
      show: false,
      id: null,
      first_name: '',
      last_name: '',
      email: '',
      phone_number: '',
      city: '',
      street_address: '',
      zipcode: '',
    });
  }

  submitForm() {
    axios({
      method: this.state.id ? 'patch' : 'post',
      url: `/api/customers${ this.state.id ? '/' + this.state.id : '' }`,
      data: {
        authenticity_token: this.props.form_authenticity_token,
        customer: {
          first_name: this.state.first_name,
          last_name: this.state.last_name,
          email: this.state.email,
          phone_number: this.state.phone_number,
          city: this.state.city,
          street_address: this.state.street_address,
          zipcode: this.state.zipcode,
        },
      }
    })
    .then((response)=> {
      this.success_message();
      this.props.refetchCustomers();
      this.hideModal();
    })
    .catch((error)=> {
      this.error_message(error);
    });
  }

  success_message() {
    if(this.state.id) {
      toastr.success(I18n.t('customers.modal.update_success'));
    } else {
      toastr.success(I18n.t('customers.modal.create_success'));
    }
  }

  error_message(error) {
    error.response.data.errors.map((error)=> {
      toastr.error(error);
    });

    if(this.state.id) {
      toastr.error(I18n.t('customers.modal.update_failed'));
    } else {
      toastr.error(I18n.t('customers.modal.create_failed'));
    }
  }

  header() {
    return(
      <Modal.Header closeButton>
        <h1>{this.state.id ? I18n.t('customers.modal.title_update') : I18n.t('customers.modal.title_create')}</h1>
      </Modal.Header>
    );
  }

  footer() {
    if (this.state.first_name && this.state.last_name && this.state.email) {
      let submit_name = this.state.id ?
                        I18n.t('customers.modal.submit_button_update') :
                        I18n.t('customers.modal.submit_button_create')
      return(
        <Modal.Footer>
          <button onClick={this.submitForm.bind(this)} className="btn btn-primary">{submit_name}</button>
        </Modal.Footer>
      );
    } else {
      return(<Modal.Footer>{I18n.t('customers.modal.form_not_filled')}</Modal.Footer>);
    }
  }

  refreshFooter() {
    this.footer();
  }

  handleChange(e) {
    this.setState({ [e.target.name]: e.target.value }, this.refreshFooter.bind(this));
  }

  content() {
    return(
      <Modal.Body>
        <form className='game-pass-form'>
          <FormGroup
            controlId="formBasicText"
          >
            <Row className="clearfix">
              <Col md={6}>
                <ControlLabel>{I18n.t('customers.modal.first_name')}</ControlLabel>
                <FormControl
                  type="text"
                  name="first_name"
                  value={this.state.first_name}
                  placeholder={I18n.t('customers.modal.first_name')}
                  onChange={this.handleChange.bind(this)}
                />
              </Col>
              <Col md={6}>
                <ControlLabel>{I18n.t('customers.modal.last_name')}</ControlLabel>
                <FormControl
                  type="text"
                  name="last_name"
                  value={this.state.last_name}
                  placeholder={I18n.t('customers.modal.last_name')}
                  onChange={this.handleChange.bind(this)}
                />
              </Col>
            </Row>
            <br/>
            <Row className="clearfix">
              <Col md={6}>
                <ControlLabel>{I18n.t('customers.modal.email')}</ControlLabel>
                <FormControl
                  type="text"
                  name="email"
                  value={this.state.email}
                  placeholder={I18n.t('customers.modal.email')}
                  onChange={this.handleChange.bind(this)}
                />
              </Col>
              <Col md={6}>
                <ControlLabel>{I18n.t('customers.modal.phone_number')}</ControlLabel>
                <FormControl
                  type="text"
                  name="phone_number"
                  value={this.state.phone_number}
                  placeholder={I18n.t('customers.modal.phone_number')}
                  onChange={this.handleChange.bind(this)}
                />
              </Col>
            </Row>
            <br/>
            <Row className="clearfix">
              <Col md={6}>
                <ControlLabel>{I18n.t('customers.modal.city')}</ControlLabel>
                <FormControl
                  type="text"
                  name="city"
                  value={this.state.city}
                  placeholder={I18n.t('customers.modal.city')}
                  onChange={this.handleChange.bind(this)}
                />
              </Col>
              <Col md={6}>
                <ControlLabel>{I18n.t('customers.modal.zipcode')}</ControlLabel>
                <FormControl
                  type="text"
                  name="zipcode"
                  value={this.state.zipcode}
                  placeholder={I18n.t('customers.modal.zipcode')}
                  onChange={this.handleChange.bind(this)}
                />
              </Col>
            </Row>
            <br/>
            <Row className="clearfix">
              <Col md={12}>
                <ControlLabel>{I18n.t('customers.modal.street_address')}</ControlLabel>
                <FormControl
                  type="text"
                  name="street_address"
                  value={this.state.street_address}
                  placeholder={I18n.t('customers.modal.street_address')}
                  onChange={this.handleChange.bind(this)}
                />
              </Col>
            </Row>
            <FormControl.Feedback />
          </FormGroup>
        </form>
        <br/><br/>
      </Modal.Body>
    );
  }

  render() {
    return(
      <Modal show={this.state.show} onHide={this.hideModal.bind(this)}
             dialogClassName="customers-modal"
             aria-labelledby="contained-modal-title-lg">
        {this.header()}
        {this.content()}
        {this.footer()}
      </Modal>
    )
  }
}
