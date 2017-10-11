var Row = ReactBootstrap.Row;
var Col = ReactBootstrap.Col;
var ControlLabel = ReactBootstrap.ControlLabel;
var FormGroup = ReactBootstrap.FormGroup;
var Label = ReactBootstrap.Label;

class GamePassTimeLimitationsSelector extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      time_options: this.time_options(),
      weekdays_options: this.weekdays_options(),
    }
  }

  time_options() {
    var times = [];

    for(var hour = 6; hour <= 22; hour++) {
      if (hour < 10) hour = `0${hour}`

      times.push(`${hour}:00`)
      times.push(`${hour}:30`)
    }
    return times.map((time)=> { return {value: time, label: time} });
  }

  weekdays_options() {
    return([
      {value: 'mon', label: I18n.t('weekdays_short.mon')},
      {value: 'tue', label: I18n.t('weekdays_short.tue')},
      {value: 'wed', label: I18n.t('weekdays_short.wed')},
      {value: 'thu', label: I18n.t('weekdays_short.thu')},
      {value: 'fri', label: I18n.t('weekdays_short.fri')},
      {value: 'sat', label: I18n.t('weekdays_short.sat')},
      {value: 'sun', label: I18n.t('weekdays_short.sun')},
    ])
  }

  clone_time_limitations() {
    return this.props.time_limitations.map((limit)=> {
      return ({
        from: limit['from'],
        to: limit['to'],
        weekdays: limit['weekdays'].splice(0),
      })
    })
  }

  handleTimeLimitationsAdd() {
    var time_limitations = this.clone_time_limitations()
    var times = this.state.time_options
    time_limitations.push({
      from: times[0]['value'],
      to: times[times.length - 1]['value'],
      weekdays: [],
    })

    this.props.update_time_limitations(time_limitations)
  }

  handleTimeLimitationsDelete(index) {
    var time_limitations = this.clone_time_limitations()
    time_limitations.splice(index, 1)

    this.props.update_time_limitations(time_limitations)
  }

  handleTimeLimitationsChange(index, key, e) {
    var time_limitations = this.clone_time_limitations()
    time_limitations[index][key] = e.value

    this.props.update_time_limitations(time_limitations)
  }

  handleTimeLimitationsWeekdaysChange(index, weekdays) {
    var time_limitations = this.clone_time_limitations()

    time_limitations[index]['weekdays'] = weekdays.map((wday)=> {
      return wday.value
    });

    this.props.update_time_limitations(time_limitations)
  }

  render() {
    return(
      <FormGroup>
        {this.render_limits()}
        <br/>
        <Row className="clearfix">
          <Col md={12}>
            <div onClick={this.handleTimeLimitationsAdd.bind(this)}
                    className="btn btn-default">
              {I18n.t('game_pass.create_game_pass_modal.add_time_limit')}
            </div>
          </Col>
        </Row>
      </FormGroup>
    )
  }

  render_limits() {
    if (this.props.time_limitations.length > 0) {
      return(
        this.props.time_limitations.map((limit, index)=> {
          return(
            <Row className="clearfix time-limitation-row" key={index}>
              <Col md={3}>
                <ControlLabel className='input-sm'>{I18n.t('game_pass.create_game_pass_modal.time_from')}</ControlLabel>
              </Col>
              <Col md={3}>
                <Select
                  name="time_from"
                  value={limit['from']}
                  options={this.state.time_options}
                  onChange={this.handleTimeLimitationsChange.bind(this, index, 'from')}
                  clearable={false}
                />
              </Col>
              <Col md={1}>
                <ControlLabel className='input-sm'>{I18n.t('game_pass.create_game_pass_modal.time_to')}</ControlLabel>
              </Col>
              <Col md={3}>
                <Select
                  name="time_to"
                  value={limit['to']}
                  options={this.state.time_options}
                  onChange={this.handleTimeLimitationsChange.bind(this, index, 'to')}
                  clearable={false}
                />
              </Col>
              <Col md={2}>
                <div onClick={this.handleTimeLimitationsDelete.bind(this, index)}
                        className="btn btn-default">
                  <i className="fa fa-trash"></i>
                </div>
              </Col>
              <Col md={3}>
                <ControlLabel className='input-sm'>{I18n.t('game_pass.create_game_pass_modal.weekdays')}</ControlLabel>
              </Col>
              <Col md={8}>
                <Select
                  name="time_weekdays"
                  multi={true}
                  value={limit['weekdays']}
                  options={this.state.weekdays_options}
                  onChange={this.handleTimeLimitationsWeekdaysChange.bind(this, index)}
                  placeholder={I18n.t('game_pass.create_game_pass_modal.any_weekday')}
                />
              </Col>
            </Row>
          )
        })
      )
    } else {
      return(
        <Row className="clearfix">
          <Col md={12}>
            <Label bsStyle="info">{I18n.t('game_pass.create_game_pass_modal.time_unlimited')}</Label>
          </Col>
        </Row>
      )
    }
  }
}
