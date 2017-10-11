var Row = ReactBootstrap.Row;
var Col = ReactBootstrap.Col;
var Tab = ReactBootstrap.Tab;
var Nav = ReactBootstrap.Nav;
var FormControl = ReactBootstrap.FormControl;
var ControlLabel = ReactBootstrap.ControlLabel;
var FormGroup = ReactBootstrap.FormGroup;
var HelpBlock = ReactBootstrap.HelpBlock;
var Checkbox = ReactBootstrap.Checkbox;

class CreateGamePassModal extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      locale: props.locale,
      show: false,
      id: null,
      template_id: 'custom',
      user_id: '',
      name: '',
      court_sports: [],
      court_type: 'any',
      start_date: null,
      end_date: null,
      price: '',
      total_charges: '',
      remaining_charges: '',
      save_as_template: false,
      template_name: '',
      time_limitations: [],
      mark_as_paid: false,
      is_paid: false,
    }
  }

  open(data = null) {
    this.setState({show: true});
    this.applyTemplate(this.state.template_id);

    if (data && data.id) {
      this.setState({
        id: data.id,
        user_id: data.user_id,
        name: data.name,
        court_sports: data.court_sports,
        court_type: data.court_type,
        start_date: this.string_to_date(data.start_date),
        end_date: this.string_to_date(data.end_date),
        price: data.price,
        total_charges: data.total_charges,
        remaining_charges: data.remaining_charges,
        time_limitations: data.time_limitations,
        is_paid: data.is_paid,
        template_id: 'custom',
        save_as_template: false,
        template_name: '',
      });
    }
  }

  hideModal() {
    this.setState({
      show: false,
      id: null,
      user_id: '',
      name: '',
      court_sports: [],
      court_type: 'any',
      start_date: null,
      end_date: null,
      price: '',
      total_charges: '',
      remaining_charges: '',
      save_as_template: false,
      template_name: '',
      time_limitations: [],
      mark_as_paid: false,
      is_paid: false,
    });
  }

  componentDidMount() {
    this.fetchUserOptions();
    this.fetchCourtSportOptions();
    this.fetchCourtTypeOptions();
    this.fetchTemplates();
  }

  fetchUserOptions() {
    axios.get(`/api/venues/${this.props.venue_id}/users.json`)
      .then((response) => {
        this.setState({ userOptions: response.data });
      });
  }

  fetchCourtSportOptions() {
    axios.get(`/api/game_passes/court_sports.json`, {
      params: {
        venue_id: this.props.venue_id
      }
    })
    .then((response) => {
      this.setState({ courtSportOptions: response.data });
    });
  }

  fetchCourtTypeOptions() {
    axios.get(`/api/game_passes/court_types.json`)
      .then((response) => {
        this.setState({ courtTypeOptions: response.data });
      });
  }

  fetchTemplates() {
    axios.get(`/api/game_passes/templates.json`, {
      params: {
        venue_id: this.props.venue_id
      }
    }).then((response) => {
      this.setState({ templates: response.data });
    });
  }

  templatesOptions() {
    var options = [{
      label: I18n.t('game_pass.create_game_pass_modal.custom_game_pass'),
      value: 'custom'
    }]
    if (this.state.templates) {
      Object.keys(this.state.templates).map((id) => {
        options.push({
          label: this.state.templates[id].template_name,
          value: id
        });
      });
    }
    return options;
  }

  date_to_string(date) {
    return date ? date.format('DD/MM/YYYY') : ''
  }

  string_to_date(string) {
    return string ? moment(string, 'DD/MM/YYYY') : null
  }

  applyTemplate(template_id) {
    if (template_id != 'custom') {
      var template = this.state.templates[template_id];
      var start_date = this.string_to_date(template.start_date);
      var end_date = this.string_to_date(template.end_date)

      if (start_date && start_date < moment()) {
        var duration = end_date - start_date;
        start_date = moment();
        end_date = moment().add(duration);
      };

      this.setState({
        name: template.name,
        court_sports: template.court_sports,
        court_type: template.court_type,
        start_date: start_date,
        end_date: end_date,
        price: template.price,
        total_charges: template.total_charges,
        remaining_charges: template.total_charges,
        time_limitations: template.time_limitations,
      });
    }
  }

  submitCreateForm() {
    var self = this;
    axios({
      method: self.state.id ? 'patch' : 'post',
      url: `/api/game_passes${ self.state.id ? '/' + self.state.id : '' }.json`,
      data: {
        authenticity_token: this.props.form_authenticity_token,
        venue_id: this.props.venue_id,
        game_pass: {
          user_id: this.state.user_id,
          name: this.state.name,
          court_sports: this.state.court_sports,
          court_type: this.state.court_type,
          start_date: this.date_to_string(this.state.start_date),
          end_date: this.date_to_string(this.state.end_date),
          price: this.state.price,
          total_charges: this.state.total_charges,
          remaining_charges: this.state.remaining_charges,
          time_limitations: this.state.time_limitations,
        },
        template_name: this.state.save_as_template ? this.state.template_name : null,
        mark_as_paid: this.state.mark_as_paid,
      }
    })
    .then(function (response) {
      self.success_message();
      self.hideModal();
      self.props.refreshGamePasses();
      self.fetchTemplates();
    })
    .catch(function (error) {
      self.error_message(error);
      console.log(error);
    });
  }

  success_message(update) {
    if(this.state.id) {
      toastr.success(I18n.t('game_pass.create_game_pass_modal.update_game_pass_success'));
    } else {
      toastr.success(I18n.t('game_pass.create_game_pass_modal.create_game_pass_success'));
    }
  }

  error_message(error) {
    if(this.state.id) {
      toastr.error(I18n.t('game_pass.create_game_pass_modal.update_game_pass_error') + error);
    } else {
      toastr.error(I18n.t('game_pass.create_game_pass_modal.create_game_pass_error') + error);
    }
  }

  header() {
    return(
      <Modal.Header closeButton>
        <h1>{I18n.t('game_pass.create_game_pass')}</h1>
      </Modal.Header>
    );
  }

  footer() {
    if (this.state.user_id && this.state.total_charges && this.state.price) {
      var submit_name = this.state.id ? I18n.t('game_pass.update_game_pass') : I18n.t('game_pass.create_game_pass')
      return(
        <Modal.Footer>
          <button onClick={this.submitCreateForm.bind(this)} className="btn btn-primary">{submit_name}</button>
        </Modal.Footer>
      );
    } else {
      return(<Modal.Footer>{I18n.t('game_pass.create_game_pass_modal.create_game_pass_form_not_filled')}</Modal.Footer>);
    }
  }

  refreshFooter() {
    this.footer();
  }

  handleChange(e) {
    this.setState({ [e.target.name]: e.target.value });
    this.refreshFooter();
  }

  handleUserChange(e) {
    this.setState({ user_id: e.value });
    this.refreshFooter();
  }

  handleCourtSportsChange(sports) {
    sports = sports.map((sport)=> {
      return sport.value
    });

    this.setState({ court_sports: sports });
  }

  handleCourtTypeChange(e) {
    this.setState({ court_type: e.value });
  }

  handleStartDateChange(date) {
    this.setState({ start_date: date });
  }

  handleEndDateChange(date) {
    this.setState({ end_date: date });
  }

  handleTemplateChange(e) {
    this.setState({ template_id: e.value });
    this.applyTemplate(e.value);
    this.refreshFooter();
  }

  handleSaveAsTemplateChange(e) {
    this.setState({ save_as_template: !this.state.save_as_template });
  }

  handleMarkPaidChange(e) {
    this.setState({ mark_as_paid: !this.state.mark_as_paid });
  }

  updateTimeLimitations(time_limitations) {
    this.setState({ time_limitations: time_limitations });
  }

  template_name_field() {
    if (this.state.save_as_template) {
      return(
        <Col md={9}>
          <ControlLabel>{I18n.t('game_pass.create_game_pass_modal.template_name')}</ControlLabel>
          <FormControl
            type="text"
            name="template_name"
            value={this.state.template_name}
            placeholder={I18n.t('game_pass.create_game_pass_modal.template_name')}
            onChange={this.handleChange.bind(this)}
          />
        </Col>
      )
    }
  }

  content() {
    return(
      <Modal.Body>
        <Row className="clearfix">
          <Col md={12}>
            <ControlLabel>{I18n.t('game_pass.create_game_pass_modal.select_template')}</ControlLabel>
            <Select
              name="template_id"
              placeholder={I18n.t('game_pass.create_game_pass_modal.select_template')}
              value={this.state.template_id}
              options={this.templatesOptions()}
              isLoading={!this.state.templates}
              onChange={this.handleTemplateChange.bind(this)}
              clearable={false}
            />
          </Col>
        </Row>
        <br/>
        <form className='game-pass-form'>
          <FormGroup
            controlId="formBasicText"
          >
            <Row className="clearfix">
              <Col md={12}>
                <ControlLabel>{I18n.t('game_pass.create_game_pass_modal.user_shown_name')}</ControlLabel>
                <FormControl
                  type="text"
                  name="name"
                  value={this.state.name}
                  placeholder={I18n.t('game_pass.create_game_pass_modal.user_shown_name')}
                  onChange={this.handleChange.bind(this)}
                />
              </Col>
            </Row>
            <br/>
            <Row className="clearfix">
              <Col md={12}>
                <ControlLabel>{I18n.t('game_pass.create_game_pass_modal.select_user')}</ControlLabel>
                <VirtualizedSelect
                  name="user_id"
                  placeholder={I18n.t('game_pass.create_game_pass_modal.select_user')}
                  value={this.state.user_id}
                  options={this.state.userOptions}
                  isLoading={!this.state.userOptions}
                  onChange={this.handleUserChange.bind(this)}
                  clearable={false}
                />
              </Col>
            </Row>
            <br/>
            <Row className="clearfix">
              <Col md={6}>
                <ControlLabel>{I18n.t('game_pass.create_game_pass_modal.select_court_sports')}</ControlLabel>
                <Select
                  name="court_sports"
                  multi={true}
                  value={this.state.court_sports}
                  options={this.state.courtSportOptions}
                  isLoading={!this.state.courtSportOptions}
                  onChange={this.handleCourtSportsChange.bind(this)}
                  placeholder={I18n.t('game_pass.create_game_pass_modal.select_court_sports_placeholder')}
                />
              </Col>
              <Col md={6}>
                <ControlLabel>{I18n.t('game_pass.create_game_pass_modal.select_court_type')}</ControlLabel>
                <Select
                  name="court_type"
                  value={this.state.court_type}
                  options={this.state.courtTypeOptions}
                  isLoading={!this.state.courtTypeOptions}
                  onChange={this.handleCourtTypeChange.bind(this)}
                  clearable={false}
                />
              </Col>
            </Row>
            <br/>
            <Row className="clearfix">
              <Col md={6}>
                <ControlLabel>{I18n.t('game_pass.create_game_pass_modal.start_date')}</ControlLabel>
                <DatePicker
                  selected={this.state.start_date}
                  minDate={moment()}
                  maxDate={this.state.end_date ? this.state.end_date : moment().add(50, "years")}
                  selectsStart={this.state.start_date && this.state.end_date}
                  startDate={this.state.start_date}
                  endDate={this.state.end_date}
                  onChange={this.handleStartDateChange.bind(this)}
                  dateFormat='DD/MM/YYYY'
                  className='form-control'
                  isClearable={true}
                  placeholderText={I18n.t('game_pass.create_game_pass_modal.start_date_placeholder')}
                />
              </Col>
              <Col md={6}>
                <ControlLabel>{I18n.t('game_pass.create_game_pass_modal.end_date')}</ControlLabel>
                <DatePicker
                  selected={this.state.end_date}
                  minDate={this.state.start_date ? this.state.start_date : moment()}
                  selectsEnd={this.state.start_date && this.state.end_date}
                  startDate={this.state.start_date}
                  endDate={this.state.end_date}
                  onChange={this.handleEndDateChange.bind(this)}
                  dateFormat='DD/MM/YYYY'
                  className='form-control'
                  isClearable={true}
                  placeholderText={I18n.t('game_pass.create_game_pass_modal.end_date_placeholder')}
                />
              </Col>
            </Row>
            <br/>
            <Row className="clearfix">
              <Col md={12}>
                <ControlLabel>{I18n.t('game_pass.create_game_pass_modal.time_limitations')}</ControlLabel>
                <GamePassTimeLimitationsSelector
                  time_limitations={this.state.time_limitations}
                  update_time_limitations={this.updateTimeLimitations.bind(this)}
                />
              </Col>
            </Row>
            <Row className="clearfix">
              <Col md={6}>
                <ControlLabel>{I18n.t('game_pass.create_game_pass_modal.total_charges')}</ControlLabel>
                <FormControl
                  type="text"
                  name="total_charges"
                  value={this.state.total_charges}
                  placeholder={I18n.t('game_pass.create_game_pass_modal.total_charges')}
                  onChange={this.handleChange.bind(this)}
                />
              </Col>

              <Col md={6}>
                <ControlLabel>{I18n.t('game_pass.create_game_pass_modal.price')}</ControlLabel>
                <FormControl
                  type="text"
                  name="price"
                  value={this.state.price}
                  placeholder={I18n.t('game_pass.create_game_pass_modal.price')}
                  onChange={this.handleChange.bind(this)}
                />
              </Col>
            </Row>
            {this.render_remaining_charges()}
            <br/>
            {this.render_mark_as_paid()}
            <br/>
            <Row className="clearfix">
              <Col md={3}>
                <Checkbox
                  onChange={this.handleSaveAsTemplateChange.bind(this)}
                  value={this.state.save_as_template}
                  >
                  {I18n.t('game_pass.create_game_pass_modal.save_as_template')}
                </Checkbox>
              </Col>
              {this.template_name_field()}
            </Row>
            <FormControl.Feedback />
          </FormGroup>
        </form>
        <br/><br/>
      </Modal.Body>
    );
  }

  // show remaining charges field on game pass edit
  render_remaining_charges() {
    if (this.state.id) {
      return(
        <Row className="clearfix">
          <Col md={6}>
            <ControlLabel>{I18n.t('game_pass.create_game_pass_modal.remaining_charges')}</ControlLabel>
            <FormControl
              type="text"
              name="remaining_charges"
              value={this.state.remaining_charges}
              placeholder={I18n.t('game_pass.create_game_pass_modal.remaining_charges')}
              onChange={this.handleChange.bind(this)}
            />
          </Col>
        </Row>
      )
    }
  }

  // show paid status or 'mark paid' checkbox on game pass edit
  render_mark_as_paid() {
    if (this.state.is_paid) {
      return(
        <Row className="clearfix">
          <Col md={12}>
            <span className='label'>{I18n.t('game_pass.create_game_pass_modal.is_paid')}</span>
          </Col>
        </Row>
      )
    }

    if (this.state.id) {
      return(
        <Row className="clearfix">
          <Col md={12}>
            <Checkbox
              onChange={this.handleMarkPaidChange.bind(this)}
              value={this.state.mark_as_paid}
              >
              {I18n.t('game_pass.create_game_pass_modal.mark_as_paid')}
            </Checkbox>
          </Col>
        </Row>
      )
    }
  }

  render() {
    return(
      <Modal show={this.state.show} onHide={this.hideModal.bind(this)}
             dialogClassName="create-game-pass-modal"
             aria-labelledby="contained-modal-title-lg">
        {this.header()}
        {this.content()}
        {this.footer()}
      </Modal>
        );
  }
}
