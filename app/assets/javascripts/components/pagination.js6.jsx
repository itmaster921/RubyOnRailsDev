class Pagination extends React.Component {
  // accepts props: page, total_pages, onPageClick, margin

  constructor(props) {
    super(props);
  }

  render() {
    return(
      <div className="pagination">
        {this.render_back_link()}
        {this.render_prev_links()}
        {this.render_current_link()}
        {this.render_next_links()}
        {this.render_forward_link()}
      </div>
    )
  }

  render_current_link() {
    return(
      <em className="current">{this.props.page}</em>
    )
  }

  render_prev_links() {
    var left_margin = Math.ceil((this.props.margin - 1)/2);

    // first link and gap
    var tail_links = [];

    if (this.props.page > 1) {
      tail_links.push(<a key="first" onClick={this.props.onPageClick.bind(this, 1)}>1</a>);

      if (this.props.page - tail_links.length > left_margin) {
        tail_links.push(<span key="left_gap" className="gap">...</span>)
      };
    };

    // rest of links with near to current numbers
    var near_links = [];

    if (left_margin >= this.props.page) {
      var near_links_count = this.props.page - 1 - tail_links.length
    } else {
      var near_links_count = left_margin - tail_links.length
    }

    for (i = 1; i <= near_links_count; i++) {
      var page = this.props.page - i;
      near_links.push(
        <a key={page} onClick={this.props.onPageClick.bind(this, page)}>{page}</a>
      )
    };

    return(tail_links.concat(near_links.reverse()))
  }

  render_next_links() {
    var right_margin = Math.ceil((this.props.margin - 1)/2);

    // last link and gap
    var tail_links = [];

    if (this.props.page < this.props.total_pages) {
      tail_links.push(
        <a key="last" onClick={this.props.onPageClick.bind(this, this.props.total_pages)}>
          {this.props.total_pages}
        </a>
      );

      if (this.props.total_pages - this.props.page > right_margin) {
        tail_links.push(<span key="right_gap" className="gap">...</span>)
      };
    };

    // rest of links with near to current numbers
    var near_links = [];

    if (right_margin >= this.props.total_pages - this.props.page) {
      var near_links_count = this.props.total_pages - this.props.page - tail_links.length
    } else {
      var near_links_count = right_margin - tail_links.length
    }

    for (i = 1; i <= near_links_count; i++) {
      var page = this.props.page + i;
      near_links.push(
        <a key={page} onClick={this.props.onPageClick.bind(this, page)}>{page}</a>
      )
    };

    return(near_links.concat(tail_links.reverse()))
  }

  render_back_link() {
    var class_name = "previous_page";

    if (this.props.page > 1) {
      var handler = this.props.onPageClick.bind(this, this.props.page - 1)
    } else {
      class_name = class_name + " disabled"
    };

    return(<a className={class_name} onClick={handler}>&lt;</a>)
  }

  render_forward_link() {
    var class_name = "next_page";

    if (this.props.total_pages > this.props.page) {
      var handler = this.props.onPageClick.bind(this, this.props.page + 1)
    } else {
      class_name = class_name + " disabled"
    };

    return(<a className={class_name} onClick={handler}>&gt;</a>)
  }
}

Pagination.defaultProps = {
  page: 1,
  total_pages: 1,
  onPageClick: null,
  margin: 11,
};
