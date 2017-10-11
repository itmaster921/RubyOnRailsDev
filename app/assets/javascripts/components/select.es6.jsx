class Select2 extends React.Component {
  constructor(props) {
    super(props);
    var data = props.data.map(function(item) {
      var text = item.court_name + ' (' + item.sport +')';
      return { id: item.id, text: text };
    });

    this.state = {
      data: data
    };
  }

  init(element) {
    this.$element = $(element);
    if (element) {
      this.$element.select2({
        data: this.state.data,
        placeholder: this.props.placeholder,
        allowClear: true,
        multiple: this.props.multiple,
      });
      this.$element.val(this.props.initialValue).trigger('change');
    }
  }

  selectAll() {
    var ids = this.state.data.map(item => item.id)
    this.$element.val(ids).trigger('change');
  }

  clear() {
    this.$element.val("").trigger('change');
  }

  render() {
    return(
      <div className="form-group">
        <label for="e1">{this.props.label}</label><br />
        <select ref={this.init.bind(this)} className="select2_demo_2 form-control" style={{width: 100 + "%"}} name={this.props.name} required={this.props.required} />
      </div>
    );
  }
}
