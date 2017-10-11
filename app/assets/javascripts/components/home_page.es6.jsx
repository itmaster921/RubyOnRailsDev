class HomePage extends React.Component {
  constructor(props) {
    super(props);
    this.searchParams = {
      time: moment().format('HH:mm'),
      date: moment().format('DD/MM/YYYY'),
      duration: 60,
      sport_name: 'tennis'
    }
    this.state = {
      locale: props.locale,
      loggedIn: props.loggedIn,
      user: props.user
    }
  }

  search(searchParams) {
    window.location = '/search?' + $.param(searchParams);
  }

  loginSuccess(user) {
    this.setState({user: user,
                  loggedIn: true});
    this.onLocaleChange(user.locale);
  }

  onLogout() {
    this.setState({user: {},
                  loggedIn: false});
  }

  join() {
    this.refs.navbar.handleSignupClick();
  }

  onLocaleChange(locale) {
    this.setState({locale: locale});
    I18n.locale = locale;
    this.forceUpdate();
  }

  render() {
    return(
      <div>
        <NavBar user={this.state.user}
                loggedIn={this.state.loggedIn}
                ref='navbar'
                loginSuccess={this.loginSuccess.bind(this)}
                onLogout={this.onLogout.bind(this)}
                headerClassName="b-header b-header_mainpage"
                className="navbar navbar-full navbar-dark">
		      <div className="container"> <div className="row">
		      		<div className="col-xs-16 col-md-12 col-md-offset-2">
		      			<div className="jumbotron jumbotron-header">
		      				<h1>{ I18n.t('pages.home.header')}</h1>
		      				<div className="lead">{ I18n.t('pages.home.header_lead')}</div>
		      			</div>
		      		</div>
		      	</div>
		      </div>
        </NavBar>
        <main className="b-page">
		      <div className="container">
		      	<div className="row">
		      		<div className="col-xs-16 col-lg-offset-1 col-lg-14 col-xl-offset-3 col-xl-10">
                <SearchGridContainer ref='searchBar' {...this.searchParams} search={this.search.bind(this)}
                                     className="search-venue"
                                     btnText={I18n.t('pages.home.find_venue')}/>

		      		</div>
		      	</div>
		      </div>
		      <div className="container-fluid jumbotron-main">

		      	<div className="container">
		      		<div className="row">
		      			<div className="col-xs-16 col-sm-offset-2 col-sm-8">
		      				<div className="jumbotron">
		      					<h2>{ I18n.t('pages.home.join_header')}</h2>
		      					<hr/>
		      					<p className="lead">{I18n.t('pages.home.join_content')}</p>

		      					<div className="lead">
                      {this.joinBtn()}
		      					</div>
		      				</div>
		      			</div>
		      		</div>
		      	</div>
		      </div>
          <VenueCarouselContainer />
        </main>
        <Footer locale={this.state.locale}
                ref='footer'
                onLocaleChange={this.onLocaleChange.bind(this)}/>
      </div>
    );
  }

  joinBtn() {
    if (this.state.loggedIn)
      return '';
    else
      return(
        <a className="btn btn-success btn-lg"
           href="#"
           data-toggle="modal"
           data-target="#signup-modal"
           role="button"
           onClick={this.join.bind(this)}>
          {I18n.t('pages.home.join_button')}
        </a>
      );
  }
}
