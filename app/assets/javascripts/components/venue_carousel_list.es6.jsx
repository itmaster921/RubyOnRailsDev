class VenueCarouselList extends React.Component {
  componentDidMount() {
    $(ReactDOM.findDOMNode(this.refs.mycarousel)).owlCarousel({
      dots: false,
      navText: ['', '']
      , rewind: true
      , mouseDrag: true
      , animateOut: 'fadeOut'
      , loop: true
      , margin: 0
      , responsiveClass: true
      , nav: true
      , responsive: {
        0: {
          items: 1
        }
        , 546: {
          items: 2
        }
        , 800: {
          items: 3
        }
        , 1440: {
          items: 3
        }
        , 1980: {
          items: 4
        }
      }
    });
  }

  shouldComponentUpdate(newProps){
    const {venues} = this.props
    const new_venues = newProps.venues
    if(new_venues !== venues) {
      return true
    } else {
      return false;
    }
  }

  componentWillUpdate() {
    $(ReactDOM.findDOMNode(this.refs.mycarousel)).trigger('destroy.owl.carousel');
  }

  componentDidUpdate() {
    $(ReactDOM.findDOMNode(this.refs.mycarousel)).owlCarousel({
      dots: false,
      navText: ['', '']
      , rewind: true
      , mouseDrag: true
      , animateOut: 'fadeOut'
      , loop: true
      , margin: 0
      , responsiveClass: true
      , nav: true
      , responsive: {
        0: {
          items: 1
        }
        , 546: {
          items: 2
        }
        , 800: {
          items: 3
        }
        , 1440: {
          items: 3
        }
        , 1980: {
          items: 4
        }
      }
    });
  }


  render () {
    return (
      <div className="venue-col-3">
        <div className="owl-carousel" ref="mycarousel">
          {this.renderVenues()}
        </div>
      </div>
    );
  }

  renderVenues() {
      return this.props.venues.map((venue) => {
        return <VenueCarouselListItem key={venue.id} venue={venue} />
      });
    }
}
