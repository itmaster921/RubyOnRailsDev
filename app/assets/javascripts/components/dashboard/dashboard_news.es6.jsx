class DashboardNews extends React.Component {

  constructor(props){
    super(props);
  }


  render () {
    return (
      <div className="col-lg-6">
        <div className="ibox float-e-margins">
            <div className="ibox-title">
                <h5>New Features</h5>
            </div>
            <div className="ibox-content">
                <div>
                    <div className="feed-activity-list">
                        <div className="feed-element">
                            <div className="media-body ">
                                <small className="pull-right">11/11/16</small>
                                <strong>Sarjakortti ominaisuus</strong> julkaistu. <br/>
                            </div>
                        </div>
                        <div className="feed-element">
                            <div className="media-body ">
                                <small className="pull-right">11/11/16</small>
                                <strong>Sähköpostilista-ominaisuus</strong> julkaistu <br/>
                            </div>
                        </div>
                        <div className="feed-element">
                            <div className="media-body ">
                                <small className="pull-right">11/11/16</small>
                                <strong>Koko päivän haku-ominaisuus</strong> julkaistu <br/>
                            </div>
                        </div>
                        <div className="feed-element">
                            <div className="media-body ">
                                <small className="pull-right">11/11/16</small>
                                <strong>Myyntiraportti-ominaisuus</strong> julkaistu <br/>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    );
  }
}
