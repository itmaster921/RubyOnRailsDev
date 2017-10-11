class VenueCarouselListItem extends React.Component {
  render () {
    if (!this.props.venue) {
      return <span/>
    }
    return (
      <div className="venue-wrap">
        <div className="venue">
          <img className="venue-img" src={this.props.venue.image} />
          <div className="venue-overlay">
            <h4 className="venue-title">{this.props.venue.name}</h4>
            <div>
              <div className="venue-attr">
                <div className="venue-attr_img icon-map-xs"></div>
                <div className="venue-attr_text">{this.props.venue.street},
                  <br />{this.props.venue.zip} {this.props.venue.city}</div>
              </div>
              <div className="venue-attr">
                <div className="venue-attr_img icon-phone"></div>
                <a className="venue-attr_text" href="">{this.props.venue.phone_number}</a>
              </div>
              <div className="venue-attr">
                <div className="venue-attr_img icon-site"></div>
                <a className="venue-attr_text" href="">{this.props.venue.website}</a>
              </div>
            </div>
            <a href={this.props.venue.url} className="venue-btn"></a>

          </div>
          <div className="venue-footer">
            <div className="venue-footer-cont">
              <div className="venue-name">{this.props.venue.name}</div>
            </div>
            <div className="venue-price">
              <span className="venue-price_currency">€</span>
              <span className="venue-price_val">{this.props.venue.lowest_price}</span>
              <span className="venue-price_plus">+</span>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
