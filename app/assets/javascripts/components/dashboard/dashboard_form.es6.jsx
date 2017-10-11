var Row = ReactBootstrap.Row;
var FormControl = ReactBootstrap.FormControl;
var ControlLabel = ReactBootstrap.ControlLabel;
var FormGroup = ReactBootstrap.FormGroup;

class DashboardForm extends React.Component {

  constructor(props){
    super(props);
    this.state = {
      title: '',
      content: ''
    }
  }

  resetForm() {
    this.setState({
      title: '',
      content: ''
    });
  }

  handleChange(e) {
    this.setState({ [e.target.name]: e.target.value });
  }

  submitCreateForm(e) {
    e.preventDefault();
    var self = this;
    axios.post(`/api/companies/${self.props.company_id}/send_support_email`, {
      title: this.state.title,
      content: this.state.content,
      authenticity_token: this.props.authenticity_token
    })
    .then(function (response) {
      toastr.success("Message sent to Playven! Thank you!");
    })
    .catch(function (error) {
      toastr.error("Message send failed, please contact developer@playven.com \n " + error);
      console.log(error);
    });
  }


  render () {
    return (
      <div className="col-lg-6">
          <div className="ibox float-e-margins">
              <div className="ibox-title">
                  <h5>Submit Support or Feature Request</h5>
              </div>
              <div className="ibox-content">
                  <div>
                    <form>
                      <FormGroup
                        controlId="formBasicText">
                        <Row className="clearfix">
                        <ControlLabel>Subject</ControlLabel>
                          <FormControl
                            type="text"
                            name="title"
                            value={this.state.title}
                            placeholder="Write Subject"
                            onChange={this.handleChange.bind(this)}
                          />
                        </Row>
                        <Row className="clearfix">
                        <ControlLabel>Message</ControlLabel>
                          <FormControl
                            name="content"
                            componentClass="textarea"
                            rows="3"
                            value={this.state.content}
                            placeholder="Content"
                            onChange={this.handleChange.bind(this)}
                          />
                        </Row>
                        <br/>
                        <Row className="clearfix">
                        <button onClick={this.submitCreateForm.bind(this)} className="btn btn-primary">Submit</button>
                        </Row>
                      </FormGroup>
                      </form>
                  </div>
              </div>
          </div>
      </div>
    );
  }
}
