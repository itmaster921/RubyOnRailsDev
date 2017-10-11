var Tab = ReactBootstrap.Tab;
var Row = ReactBootstrap.Row;
var Col = ReactBootstrap.Col;
var Nav = ReactBootstrap.Nav;
var NavItem = ReactBootstrap.NavItem;
var Modal = ReactBootstrap.Modal;

class GamePassPage extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      locale: props.locale,
      game_passes: [],
      venue_id: props.venue_id,
    }
  }

  componentWillMount() {
    this.getGamePasses();
  }

  getGamePasses() {
    var self = this;
    axios.get('/api/game_passes.json/', {
     params: {
      venue_id: self.props.venue_id
     }
    })
    .then(function (response) {
      self.setState({
        game_passes: response.data.game_passes
      });
    })
    .catch(function (error) {
      console.log(error);
    });
  }

  openCreateGamePassModal() {
    this.refs.createGamePassModal.open();
  }

  editGamePass(id) {
    var self = this;
    axios.get(`/api/game_passes/${id}.json`)
    .then(function (response) {
      self.refs.createGamePassModal.open(response.data);
    })
    .catch(function (error) {
      console.log(error);
    });
  }

  deleteGamePass(id) {
    var self = this;
    swal({
      title: I18n.t('game_pass.confirm_delete_title'),
      text: I18n.t('game_pass.confirm_delete_text'),
      type: "warning",
      showCancelButton: true,
      confirmButtonText: I18n.t('game_pass.confirm_delete_button')
    }, (isConfirmed)=> {
      if (isConfirmed) {
        axios.delete(`/api/game_passes/${id}.json`)
        .then(function (response) {
          self.getGamePasses();
          toastr.success(I18n.t('game_pass.create_game_pass_modal.delete_game_pass_success'));
        })
        .catch(function (error) {
          toastr.success(I18n.t('game_pass.create_game_pass_modal.delete_game_pass_success'));
        });
      }
    });
  }

  render() {
      return(
        <div className="wrapper wrapper-content  animated fadeInRight">
          <div className="row">
            <div className="col-sm-12">
              <div className="ibox">
                <div className="ibox-content">
                  <h2>{I18n.t('game_pass.game_pass')}</h2>
                  <p>
                    <button onClick={this.openCreateGamePassModal.bind(this)}
                      className="btn btn-primary">{I18n.t('game_pass.create_game_pass')}</button>
                  </p>
                  <Tab.Container id="tabs-with-dropdown" defaultActiveKey="first">
                    <Row className="clearfix">
                      <Col sm={12}>
                        <Nav bsStyle="tabs">
                          <NavItem eventKey="first">
                            {I18n.t('game_pass.game_pass_list')}
                          </NavItem>
                        </Nav>
                      </Col>
                      <Col sm={12}>
                        <Tab.Content animation>
                          <Tab.Pane eventKey="first">
                          <GamePassList locale={this.state.locale}
                            game_passes={this.state.game_passes}
                            edit_game_pass={this.editGamePass.bind(this)}
                            delete_game_pass={this.deleteGamePass.bind(this)}
                          />
                          </Tab.Pane>
                        </Tab.Content>
                      </Col>
                    </Row>
                  </Tab.Container>
                </div>
              </div>
            </div>
          </div>
          <CreateGamePassModal ref='createGamePassModal'
            venue_id={this.props.venue_id}
            locale={this.props.locale}
            form_authenticity_token={this.props.form_authenticity_token}
            refreshGamePasses={this.getGamePasses.bind(this)}
          />
        </div>
      );
    }
}
