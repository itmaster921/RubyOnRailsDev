class RemoteForm extends React.Component {
  constructor(props) {
    super(props);
  }

  submit() {
    this.$form.submit();
  }

  init(form) {
    this.$form = $(form);
    var self = this;
    var validator = this.$form.validate({
      submitHandler: function(form) {
        $.ajax({
          url: self.props.actionUrl,
          type: 'put',
          data: self.$form.serialize(),
          success: self.props.onSuccess,
          error: self.props.onError
        });
      }
    });
  }

  render() {
    return(
      <form action={this.props.actionUrl}
            ref={this.init.bind(this)}>
        {this.props.children}
      </form>
    );
  }
}
