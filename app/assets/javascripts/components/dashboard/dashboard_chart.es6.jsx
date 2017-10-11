class DashboardChart extends React.Component {

  constructor(props){
    super(props);
  }

  componentDidUpdate() {
    var chart = new Chart(document.getElementById('barchart'), {type: 'bar', data: this.props.chartData, options: this.props.chartOptions});
  }


  render () {
    return (
      <div>
        <canvas height="60" id="barchart">WTF?</canvas>
      </div>
    );
  }
}
