var Modal = ReactBootstrap.Modal;
var Button = ReactBootstrap.Button;

var _membershipModal;

class MembershipModal extends React.Component {
  constructor(props) {
    super(props);
    _membershipModal = this;
    this.state = {
      showModal: false,
      membership: {
      }
    };
  }

  close() {
    this.setState({showModal: false});
  }

  open(url) {
    var self = this;
    $.ajax({
      url: url,
      success: function(resp) {
        self.setState({showModal: true,
                       membership: resp.membership});
      }
    });
  }

  init(form) {
    this.$form = $(form);
    this.$form.validate({
      rules: {
        "membership[start_time]": {
          required: true,
          validTime: true
        },
        "membership[end_time]": {
          required: true,
          validTime: true
        },
        "membership[start_date]": {
          required: true,
          validDate: true
        },
        "membership[end_date]": {
          required: true,
          validDate: true
        }
      }
    });
  }


  render() {
    return(
      <Modal show={this.state.showModal} onHide={this.close.bind(this)}>
        {this.header()}
        {this.content()}
        {this.footer()}
      </Modal>
    );
  }

  header() {
    return(
      <Modal.Header>
        <Modal.Title>{I18n.t('venues.memberships.edit_membership')}</Modal.Title>
      </Modal.Header>
    );
  }

  content() {
    return(
      <Modal.Body>
        <form action={this.state.membership.update_url}
              ref={this.init.bind(this)}
              method='post'
              id='membership-form'>
          <input type='hidden' value={this.props.authenticityToken} name="authenticity_token"/>
          <div className="row">
            <div className="col-md-9">
              <Select2 label={ I18n.t('venues.memberships_new.select_court_label')}
                      data={this.props.courts}
                      placeholder="Select Court"
                      name="membership[court_id]"
                      initialValue={this.state.membership.court}
                      required />
            </div>
          </div>
          <div className="row">
            <div className="col-md-9">
              <div className="form-group">
                <label >{ I18n.t('venues.memberships_new.select_weekday_label')}</label>
                <select name="membership[weekday]" className="select2_demo_2 form-control" style={{width: 100 + '%'}} defaultValue={this.state.membership.weekday}>
                <option value="monday">{ I18n.t('date.day_names')[1] }</option>
                <option value="tuesday">{ I18n.t('date.day_names')[2] }</option>
                <option value="wednesday">{ I18n.t('date.day_names')[3] }</option>
                <option value="thursday">{ I18n.t('date.day_names')[4] }</option>
                <option value="friday">{ I18n.t('date.day_names')[5] }</option>
                <option value="saturday">{ I18n.t('date.day_names')[6] }</option>
                <option value="sunday">{ I18n.t('date.day_names')[0] }</option>
                </select>
              </div>
            </div>
          </div>
          <div className="row">
            <div className="col-md-9">
              <div className="form-group has-feedback">
                  <label className="control-label">{ I18n.t('venues.memberships_new.price_label')}</label>
                  <input type="text" className="form-control" placeholder={ I18n.t('venues.memberships_new.price_label')}  name="membership[price]" required='true' data-rule-number='true' defaultValue={this.state.membership.price}/>
                  <i className="fa fa-eur form-control-feedback"></i>
              </div>
            </div>
          </div>

          <div className="row">
            <div className="col-md-9">
                <ClockPicker label={ I18n.t('venues.memberships_new.select_start_time')}
                             name={"membership[start_time]"}
                             initialValue={this.state.membership.start_time}/>
            </div>
          </div>
          <div className="row">
            <div className="col-md-9">
                <ClockPicker label={ I18n.t('venues.memberships_new.select_end_time')}
                             name={"membership[end_time]"}
                             initialValue={this.state.membership.end_time}/>
            </div>
          </div>
          <div className="row">
            <div className="col-md-9">
                <DatePickerJquery label={ I18n.t('venues.memberships_new.membership_start_date')}
                             name={"membership[start_date]"}
                             initialValue={this.state.membership.start_date}/>
            </div>
          </div>
          <div className="row">
            <div className="col-md-9">
                <DatePickerJquery label={ I18n.t('venues.memberships_new.membership_end_date')}
                             name={"membership[end_date]"}
                             initialValue={this.state.membership.end_date}/>
            </div>
          </div>
       </form>
      </Modal.Body>
    );
  }

  footer() {
    return(
       <Modal.Footer>
         <input type='submit' className="btn btn-default" text={I18n.t('venues.memberships.update_button')} form='membership-form'/>
         <Button className="btn btn-default" onClick={this.close.bind(this)}>
           {I18n.t('venues.memberships.cancel_button')}
         </Button>
       </Modal.Footer>
    );
  }
}
