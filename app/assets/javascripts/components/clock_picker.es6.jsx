class ClockPicker extends React.Component {
  constructor(props) {
    super(props);
  }

  initPicker(element) {
    var $element = $(element);
    if ($element) {
      $element.clockpicker({
        placement: 'bottom',
        autoclose: true,
      });
    }
  }

  // Clock picker is assumed to be always required
  // if needed extend with a required property
  render() {
    return(
      <div className="form-group">
        <label>{this.props.label}</label>
        <div ref={this.initPicker} className="input-group clockpicker" data-autoclose="true">
          <input type="text" className="form-control" name={this.props.name} required defaultValue={this.props.initialValue}/>
          <span className="input-group-addon">
            <span className="fa fa-clock-o"></span>
          </span>
        </div>
      </div>
    );
  }
}
