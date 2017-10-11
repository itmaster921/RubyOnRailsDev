class DashboardPage extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      times: [],
      rates: [],
      chartData: {
        labels: [],
        datasets: [
            {
                data: [],
            }
        ]

      },
      chartOptions: {
            legend: {
                    display: false
            },
            scales: {
                xAxes: [{
                    gridLines: {
                        display: false,
                        drawBorder: false
                    },
                }],
                yAxes: [{
                    gridLines: {
                        color: 'rgba(255, 255, 255, 0.1)',
                        zeroLineColor: 'rgba(255, 255, 255, 0.1)'
                    },
                    stacked: true,
                }]
            }
        }
    }
  }

  componentWillMount() {
    this.fetchUtilizationRates(this.props.venue_ids[0]);
  }

  componentDidUpdate() {
    this.chartInit.bind(this);
  }

  chartInit() {
    return(
        <DashboardChart chartData={this.state.chartData} chartOptions={this.state.chartOptions} />
    );
  }

  fetchUtilizationRates(venue_id) {
    var self = this;
    axios.get(`/api/venues/${venue_id}/utilization_rate.json`, {
    })
    .then(function (response) {
      var bgColors = []
      for (let rate of response.data.rates) {
        bgColors.push('rgba(14, 125, 255, ' + (rate/100) +')');
      }
      self.setState({
        times: response.data.times,
        rates: response.data.rates,
        chartData: {
            labels: response.data.times,
            datasets: [
                {
                    backgroundColor: bgColors,
                    data: response.data.rates,
                }
            ]
        }
      });
    })
    .catch(function (error) {
      console.log(error);
    });
  }
  render() {

    var chartData = {
        labels: ["January", "February", "March", "April", "May", "June", "July"],
        datasets: [
            {
                data: [65, 59, 80, 81, 56, 55, 40],
            }
        ]
    }

    var chartOptions = {
        legend: {
                display: false
        },
        scales: {
            xAxes: [{
                gridLines: {
                    display: false,
                    drawBorder: false
                },
            }],
            yAxes: [{
                gridLines: {
                    color: 'rgba(255, 255, 255, 0.1)',
                    zeroLineColor: 'rgba(255, 255, 255, 0.1)'
                },
                stacked: true,
            }]
        }
    }

    return(
    <div>
        <div className="row  border-bottom white-bg dashboard-header">
            <div className="col-sm-12">
                <h2>Utilization Rate on {moment().format('DD/MM/YYYY')}</h2>
                <br/>
                {this.chartInit()}
            </div>

        </div>
        <div className="row">
            <div className="col-lg-12">
                <div className="wrapper wrapper-content">
                    <DashboardNews />
                    <DashboardForm company_id={this.props.company_id}
                                   authenticity_token={this.props.form_authenticity_token}
                     />
                </div>
            </div>
        </div>
    </div>
    );
  }

}
