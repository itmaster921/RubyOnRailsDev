class Footer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      locale: props.locale
    };
  }

  render() {
    return(
      <footer className="b-footer">
        <div className="container">
          <div className="row">
            <div className="col-xs-6 col-sm-1 col-xs-offset-0 col-sm-offset-2">
              <i className="icon-logo_grey"></i>
            </div>
            <div className="col-xs-9 col-sm-4 col-xs-offset-1">
              <ul className="nav">
                <li className="nav-item">
                  <a className="nav-link" href="https://amper.zendesk.com/hc/en-us">
                    { I18n.t('layouts.footer.help') }
                  </a>
                </li>
                <li className="nav-item">
                  <a className="nav-link" href="/termsofuse">
                    { I18n.t('layouts.footer.terms') }
                  </a>
                </li>
                <li className="nav-item">
                  <a className="nav-link" href="/privacypolicy">
                    {I18n.t('layouts.footer.privacy')}
                  </a>
                </li>
              </ul>
            </div>
            <div className="col-xs-16 col-sm-6 col-sm-offset-1 col-md-3  col-md-offset-3">
              <div className="b-footer-download-text"
                   dangerouslySetInnerHTML={{__html: I18n.t('layouts.footer.download_text_html')}}>
              </div>
              <a href="https://appsto.re/i6Ss2zr" className="b-footer-download"
                 dangerouslySetInnerHTML={{__html: I18n.t('layouts.footer.download_ios_html')}}>
              </a>
            </div>
          </div>

          <div className="row">
            <div className="col-xs-16 col-sm-14 col-sm-offset-1 col-md-offset-2 col-md-12">
              <hr/>
              <div className="row">
                <div className="col-xs-8 col-sm-8">

                <div className="b-footer-social">
                  { I18n.t('layouts.footer.follow') }
                  <a className="b-footer-social-btn_fb" href="https://www.facebook.com/ampersports/"></a>
                  <a className="b-footer-social-btn_tw" href="https://twitter.com/ampersports"></a>
                </div>
                </div>
                <div className="col-xs-8 col-sm-8">
                  <div className="b-footer-lang">
                    <div className="dropdown dropup">
                      {this.lang()}
                      <div className="dropdown-menu dropdown-menu-right" aria-labelledby="js-dropdown-menu-lang" role="menu">
                        {this.langDropdown('flag/us.png', 'English')}
                        {this.langDropdown('flag/finn.png', 'Finnish')}
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </footer>
    );
  }

  langDropdown(image, text) {
    return(
	    <a className="dropdown-item" href="<%= @en_url %>">
        <img src={image}/> {text}
	    </a>
    );
  }

  lang() {
    if (this.state.locale == 'fi') {
      var image = 'flags/finn.png'
      var text = 'Soumi'
    } else if (this.state.locale == 'EN') {
      var image = 'flags/us.png'
      var text = 'English'
    }
    return(
      <button className="b-footer-lang__link"
              id="js-dropdown-menu-lang"
              data-toggle="dropdown"
              aria-haspopup="true"
              aria-expanded="false">
        <img src={image} />
        <span>{text}</span>
      </button>
    );
  }
}
