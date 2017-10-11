class DatePickerJquery extends React.Component {
  constructor(props) {
    super(props);
  }

  initPicker(element) {
    var $element = $(element);
    $element.datepicker({
      orientation: " auto",
      calendarWeeks: true,
      autoclose: true,
      todayHighlight: true,
      format: 'dd/mm/yyyy',

    });
  }

  // Clock picker is assumed to be always required
  // if needed extend with a required property
  render() {
    return(
    <div className="form-group">
      <label >{ this.props.label}</label>
      <div ref={this.initPicer} className="input-group date" data-date-format="dd/mm/yyyy" data-provide="datepicker">
        <input type="text" className="form-control" id="membership-start" data-date-format="dd/mm/yyyy" defaultValue={ this.props.initialValue } name={this.props.name} required />
        <div className="input-group-addon">
          <span className="fa fa-calendar"></span>
        </div>
      </div>
    </div>
    );
  }
}
