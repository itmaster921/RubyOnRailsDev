$(function () {
  if ($('.dashboard-chart').length) {
    var getCompanyRev = getRevenue('/companies/' + $('#company-info').val() + '/revenue', 'revenue');
    var getCompanyResv = getRevenue('/companies/' + $('#company-info').val() + '/resv', 'resv');
    getCompanyRev('day');
    getCompanyResv('day');
    $(".btn-revenue-view").click(function () {
      getCompanyRev($(this).data('view'));
    });
    $(".btn-resv-view").click(function () {
      getCompanyResv($(this).data('view'));
    });
  }
});

function getRevenue(path, placeholder) {
  return function(grouping) {
    $.ajax({
      url: path,
      method: "get",
      data: {
        grouping: grouping
      },
      success: function(resp) {
        var poptions = plotOptions(grouping);
        $('small.' + placeholder).text(viewName(grouping));
        $('.dashboard-chart.' + placeholder).plot([resp], poptions);
      }
    });
  }
}

function viewName(grouping) {
  var now = moment(new Date());
  switch(grouping) {
    case "day":
      return now.format("DD MMMM YYYY");
    case "month":
      return now.format("MMMM YYYY");
    case "year":
      return now.format("YYYY");
  }
}

function plotOptions(grouping) {
  var poptions = {};
  poptions.xaxis = {};
  switch(grouping) {
    case "month": {
      poptions.xaxis.timeformat = "%d";
      poptions.xaxis.min = startOfMonth;
      poptions.xaxis.max = startOfNextMonth;
      poptions.xaxis.ticks = 30;
      break;
    }
    case "year": {
      poptions.xaxis.timeformat = "%b";
      poptions.xaxis.min = startOfYear;
      poptions.xaxis.max = startOfNextYear;
      poptions.xaxis.ticks = 12;
      break;
    }
    default: {
      poptions.xaxis.timeformat = "%H:%M";
      poptions.xaxis.min = startOfDay;
      poptions.xaxis.max = startOfNextDay;
      poptions.xaxis.ticks = 24;
    }
  }
  poptions.xaxis.mode = "time";
  poptions.xaxis.timezone = "browser";
  return poptions;
}
