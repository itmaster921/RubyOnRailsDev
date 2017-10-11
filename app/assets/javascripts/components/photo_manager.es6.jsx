class PhotoManager extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      sliderConfig: {
        dots: true,
        slidesToShow: Math.min(3, props.images.length),
        sliderToScroll: 1,
        variableWidth: true,
        infinite: false,
      },

      dropzoneConfig: {
        iconFiletypes: ['.jpg', '.png', '.gif'],
        showFiletypeIcon: true,
        postUrl: props.url
      },

      eventHandlers: {
        success: this.handleAdd.bind(this)
      },

      djsConfig: {
        headers: {
          "X-CSRF-Token": props.auth_token
        }
      },

      images: props.images,
    };
  }

  handleAdd(file, resp) {
    var sliderConfig = this.state.sliderConfig;
    sliderConfig.slidesToShow = Math.min(3, resp.images.length);
    this.setState({sliderConfig: sliderConfig,
                   images: resp.images,
                   main: resp.main});
  }

  handleDelete(resp) {
    this.setState({images: resp.images});
    return false;
  }

  handleClick(url) {
    var self = this;
    $.ajax({
      type: 'post',
      url: url,
      success: function(resp) {
        self.setState({images: resp.images});
      }
    });
    return false;
  }

  render () {
    var self = this;
    var images = this.state.images.map(function(image, index) {
      return(
        <div className='venue-image' key={index}>
          <Photo image={image}
                 key={index}
                 handleClick={self.handleClick.bind(self, image.main_url)}
                 onDelete={self.handleDelete.bind(self)}/>
        </div>
      );
    });

    return (
      <div>
        <DropzoneComponent config={this.state.dropzoneConfig}
                           eventHandlers={this.state.eventHandlers}
                           djsConfig={this.state.djsConfig} />
        <br/>
        <Slider {...this.state.sliderConfig}>
          {images}
        </Slider>
      </div>);
  }
}
