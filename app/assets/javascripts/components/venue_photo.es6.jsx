class Photo extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      deleting: false
    };
  }

  handleDelete(e) {
    e.stopPropagation();
    var self = this;
    $.ajax({
      type: 'DELETE',
      url: self.props.image.delete_url,
      success: function(resp, data) {
        self.props.onDelete(resp);
        self.setState({deleting: false});
      }
    });
    this.setState({deleting: true});
    return false;
  }

  render() {
    var imgCss = 'venue-inner-image ' + (this.props.image.main ? 'venue-main-image' : '' );
    return(
      <div className='venue-image' onClick={this.props.handleClick}>
        <button className='venue-del-image'
                aria-label="Delete Photo"
                onClick={this.handleDelete.bind(this)}>&times;</button>
        <img src={this.props.image.url}
             className={imgCss}
             height='100'/>

      </div>
    );
  }
}
