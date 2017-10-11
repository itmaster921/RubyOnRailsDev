var Table = ReactBootstrap.Table;
var Row = ReactBootstrap.Row;
var Col = ReactBootstrap.Col;
var Button = ReactBootstrap.Button

class CustomersTable extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      customers: [],
      search: '',
      page: 1,
      per_page: 10,
      total_pages: 1,
      loading: false,
    }
    this.search_timer = null;
  }

  componentDidMount() {
    this.fetchCustomers();
  }

  fetchCustomers() {
    this.setState({ loading: true });
    axios.get('/api/customers', {
      params: {
        search: this.state.search,
        page: this.state.page,
        per_page: this.state.per_page,
      }
    })
    .then((response)=> {
      // refetch correct last page if current page is out of customers
      if (this.state.page > response.data.total_pages ) {
        this.setState({
          page: response.data.total_pages,
        }, this.fetchCustomers.bind(this));
      } else {
        this.setState({
          customers: response.data.customers,
          total_pages: response.data.total_pages,
        });
      }
      this.setState({ loading: false });
    })
    .catch((error)=> {
      error.response.data.errors.map((error)=> {
        toastr.error(error);
      });
    });
  }

  handleCreateClick() {
    this.refs.customersModal.open();
  }

  handleEditClick(id) {
    axios.get(`/api/customers/${id}`)
    .then((response)=> {
      this.refs.customersModal.open(response.data);
    })
    .catch((error)=> {
      error.response.data.errors.map((error)=> {
        toastr.error(error);
      });
    });
  }

  handleDeleteClick(id) {
    swal({
      title: I18n.t('customers.table.confirm_delete_title'),
      text: I18n.t('customers.table.confirm_delete_text'),
      type: "warning",
      showCancelButton: true,
      confirmButtonText: I18n.t('customers.table.confirm_delete_button')
    }, (isConfirmed)=> {
      if (isConfirmed) {
        axios.delete(`/api/customers/${id}`)
        .then((response)=> {
          this.fetchCustomers();
          toastr.success(I18n.t('customers.table.delete_success'));
        })
        .catch((error)=> {
          error.response.data.errors.map((error)=> {
            toastr.error(error);
          });
          toastr.error(I18n.t('customers.table.delete_failed'));
        });
      }
    });
  }

  // starts search request after delay if typing ended
  // deley will be zero for [enter] press
  handleSearch(e) {
    let delay = 500;
    if (e.keyCode == 13) delay = 0;

    this.setState({ search: e.target.value, page: 1 }, this.run_search.bind(this, delay));
  }

  run_search(delay) {
    clearTimeout(this.search_timer);
    this.search_timer = setTimeout(this.fetchCustomers.bind(this) , delay);
  }

  handlePageClick(page) {
    this.setState({ page: page }, this.fetchCustomers.bind(this));
  }

  // TODO(aytigra): add spinner while this.state.loading
  render() {
    return(
      <div>
        <Row className="clearfix">
          <Col md={12}>
            <Button bsStyle="primary" onClick={this.handleCreateClick.bind(this)}>
              {I18n.t('customers.table.create_customer')}
            </Button>
          </Col>
        </Row>
        <br />
        <Row className="clearfix">
          <Col md={12}>
            <FormControl
              type="text"
              name="search"
              value={this.state.search}
              placeholder={I18n.t('customers.table.search_placeholder')}
              onChange={this.handleSearch.bind(this)}
              onKeyUp={this.handleSearch.bind(this)}
            />
          </Col>
        </Row>
        <Table responsive>
          <thead>
            <tr>
              <th>{I18n.t('customers.table.full_name')}</th>
              <th>{I18n.t('customers.table.email')}</th>
              <th>{I18n.t('customers.table.phone_number')}</th>
              <th>{I18n.t('customers.table.address')}</th>
              <th>{I18n.t('customers.table.outstanding_balance')}</th>
              <th>{I18n.t('customers.table.reservations_done')}</th>
              <th></th>
            </tr>
          </thead>
          {this.render_body()}
        </Table>
        <div className="text-center">
          <Pagination
            page={this.state.page}
            total_pages={this.state.total_pages}
            onPageClick={this.handlePageClick.bind(this)}
          />
        </div>

        <CustomersModal ref='customersModal'
          form_authenticity_token={this.props.form_authenticity_token}
          refetchCustomers={this.fetchCustomers.bind(this)}
        />
      </div>
    )
  }

  render_body() {
    if (this.state.customers.length) {
      return(this.render_customers())
    }
    else {
      return(
        <tbody>
          <tr>
            <td colSpan="9">
              {I18n.t('customers.table.empty')}
            </td>
          </tr>
        </tbody>
      )
    }
  }

  render_customers() {
    let customers = this.state.customers.map((customer, index)=> {
      return(this.render_customer(customer, index));
    });

    return(
      <tbody>
        {customers}
      </tbody>
    )
  }

  render_customer(customer, index) {
    return(
      <tr key={customer.id}>
        <td>{customer.first_name} {customer.last_name}</td>
        <td>{customer.email}</td>
        <td>{customer.phone_number}</td>
        <td>{customer.city}, {customer.street_address}, {customer.zipcode}</td>
        <td>{customer.outstanding_balance}</td>
        <td>{customer.reservations_done}</td>
        <td>
          <ButtonToolbar>
            <Button bsStyle="primary" onClick={this.handleEditClick.bind(this, customer.id)}>
              <i className="fa fa-pencil"></i>
            </Button>
            <Button bsStyle="danger" onClick={this.handleDeleteClick.bind(this, customer.id)}>
              <i className="fa fa-trash"></i>
            </Button>
          </ButtonToolbar>
        </td>
      </tr>
    )
  }
}
