var OverlayTrigger = ReactBootstrap.OverlayTrigger;
var Popover = ReactBootstrap.Popover;
var ButtonToolbar = ReactBootstrap.ButtonToolbar
var Button = ReactBootstrap.Button

class GamePassListItem extends React.Component {
  constructor(props) {
    super(props);
  }

  handleEditClick(id) {
    this.props.edit_game_pass(id);
  }

  handleDeleteClick(id) {
    this.props.delete_game_pass(id);
  }

  render() {
    return (
      <tr key={this.props.game_pass.id}>
        <td>{this.props.game_pass.user.first_name} {this.props.game_pass.user.last_name}</td>
        <td>{this.props.game_pass.total_charges}</td>
        <td>{this.props.game_pass.remaining_charges}</td>
        <td>{this.props.game_pass.price}</td>
        <td>
          <OverlayTrigger trigger={['hover', 'focus']} placement="bottom" overlay={this.limitations_popover()}>
            <div className="btn btn-default"><i className="fa fa-info"></i></div>
          </OverlayTrigger>
        </td>
        <td>
          <ButtonToolbar>
            <Button bsStyle="primary" onClick={this.handleEditClick.bind(this, this.props.game_pass.id)}>
              <i className="fa fa-pencil"></i>
            </Button>
            <Button bsStyle="danger" onClick={this.handleDeleteClick.bind(this, this.props.game_pass.id)}>
              <i className="fa fa-trash"></i>
            </Button>
          </ButtonToolbar>
        </td>
      </tr>
    );
  }

  limitations_popover() {
    return (
      <Popover style={{'maxWidth': 'none', 'width': '500px'}}
               id="limitations-info-popover">
        <Row className="clearfix">
          <Col md={4}>
            <ControlLabel>{I18n.t('game_pass.court_sports')}</ControlLabel>
          </Col>
          <Col md={8}>
            {this.props.game_pass.court_sports}
          </Col>
        </Row>
        <Row className="clearfix">
          <Col md={4}>
            <ControlLabel>{I18n.t('game_pass.court_type')}</ControlLabel>
          </Col>
          <Col md={8}>
            {this.props.game_pass.court_type}
          </Col>
        </Row>
        <Row className="clearfix">
          <Col md={4}>
            <ControlLabel>{I18n.t('game_pass.dates_limit')}</ControlLabel>
          </Col>
          <Col md={8}>
            {this.props.game_pass.dates_limit}
          </Col>
        </Row>
        <Row className="clearfix">
          <Col md={4}>
            <ControlLabel>{I18n.t('game_pass.time_limitations')}</ControlLabel>
          </Col>
          <Col md={8}>
            {this.props.game_pass.time_limitations}
          </Col>
        </Row>
      </Popover>
    );
  }
}
