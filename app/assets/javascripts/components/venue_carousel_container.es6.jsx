class VenueCarouselContainer extends React.Component {

  constructor(props) {
    super(props)
    this.state = { sport: 'tennis', venues: [] }
  }

  set_sport(sport) {
    this.setState({ sport });

    $.ajax({
      url: `/api/sort_by_sport.json/?sport=${sport}`,
      method: 'GET',
      success: (data) => {
        this.setState({
          venues: data
        });
      }
    });
  }

  render () {
    return (
      <div className="container">
        <div className="row">
          <div className="col-xs-16 col-md-12 col-md-offset-2">
              <VenueCarouselSportList sport={this.state.sport} onSetSportSportChange={(sport) => {this.set_sport(sport)}}/>
          </div>
        </div>
        <VenueCarouselList venues={this.state.venues} />
      </div>
    );
  }
}

