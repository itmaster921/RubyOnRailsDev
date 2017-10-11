var _priceModal;

class PriceModal extends React.Component {
  constructor(props) {
    super(props);
    _priceModal = this;
    this.WindowEnum = {
      SHOW: 0,
      EDIT: 1
    };
    this.state = {
      showModal: false,
      showing: this.WindowEnum.SHOW,
      price: {
        courts: [],
        days: []
      }
    };
  }

  close() {
    this.setState({showModal: false});
  }

  open(url) {
    this.setState({showing: this.WindowEnum.SHOW});
    var self = this;
    $.ajax({
      url: url,
      success: function(resp) {
        self.setState({showModal: true,
                       price: resp.price});
      }
    });
  }

  handleChangedWindow(newWindow) {
    this.setState({showing: newWindow});
  }

  render() {
    var params = {
      price: this.state.price,
      closeHandler: this.close.bind(this),
      showModal: this.state.showModal
    }
    if (this.state.showing == this.WindowEnum.SHOW) {
      return(
        <Price can_manage={this.props.can_manage}
               windowEnum = {this.WindowEnum}
               changeWindow = {this.handleChangedWindow.bind(this)}
               {...params}/>

      );
    } else if (this.state.showing == this.WindowEnum.EDIT) {
      return(
        <PriceForm courts={this.props.courts}
                   {...params}/>
      );
    }
  }
}
