(function () {

  angular.module('compass').controller('PerformanceCtrl', ['$scope', '$resource', '$interval', 'userService', performance]);

  function performance($scope, $resource, $interval, userService) {
    var dashboardResource = $resource('dashboard/performance');
    var user = userService.getCurrentUser();
    $scope.graph = graph;
    $scope.googleConnected = true;
    $scope.enoughData = false;
    $scope.lifestageCompleted = user.lifestage_state == 'complete';
    $scope.activeLink = "uniqueVisitors";

    getPerformance();

    $scope.$on('surveyComplete', function() {
      $scope.lifestageCompleted = userService.getCurrentUser().lifestage_state == 'complete';
    });

    var refresh = $interval(refreshPerformance, 15000, 5);

    $scope.$on('$destroy', function() {
      stopRefresh();
    });

    function stopRefresh() {
      if (angular.isDefined(refresh)) {
        $interval.cancel(refresh);
        refresh = undefined;
      }
    }

    function refreshPerformance() {
      if ($scope.enoughData) {
        return;
      }
      getPerformance();
    }

    function getPerformance() {
      dashboardResource.get().$promise
        .then(function(response) {
          $scope.dashboard = response;
          $scope.googleConnected = response.google_connected;

          if ($scope.googleConnected && $scope.lifestageCompleted){
            $scope.enoughData = ( response.unique_visitors ? response.unique_visitors.company.length >= 9 : false );
          }

          mapGraph($scope.dashboard.unique_visitors, 'Count', user.company_name, 'Unique Visitors');

        });
    }

    function graph(type){
      if (type === 'unique') {
        mapGraph($scope.dashboard.unique_visitors, 'Count', user.company_name, 'Unique Visitors');
        $scope.activeLink = "uniqueVisitors";
      }
      if (type === 'time' ) {
        mapGraph($scope.dashboard.time_on_site, 'Seconds', user.company_name, 'Time on Site');
        $scope.activeLink = "timeOnSite";
      }
      if (type === 'bounce' ) {
        mapGraph($scope.dashboard.bounce_rate, '%', user.company_name, 'Bounce Rate');
        $scope.activeLink = "bounceRate";
      }
      if (type === 'returning' ) {
        mapGraph($scope.dashboard.returning_visitors, 'Count', user.company_name, 'Returning Visitors');
        $scope.activeLink = "returningVisitors";
      }
    }


    function largestDateRange(data) {
      var possibleRanges = [data.top, data.bottom, data.company];

      // get largest range
      return possibleRanges.sort(function(a, b) {return a.length - b.length;})[2].map(function(x) {return x.date;});
    }

    var maxYaxis = null;
    function mapGraph(data, yAxisUnit, title, exportName) {
      if(data === null) {
        return;
      }


      if (yAxisUnit == '%'){
        maxYaxis = 100;
      }else{
        maxYaxis = null;
      }

      $scope.chartData = {
        chart: {
          style: {
            fontFamily: 'Open Sans'
          }
        },
        title: {
          text: ''
        },
        xAxis: {
          gridLineWidth: 0,
          type: 'datetime',
          categories: largestDateRange(data)
        },
        yAxis: {
          gridLineWidth: 0,
          minorGridLineWidth: 0,
          min: 0,
          max: maxYaxis,
          title: {
            text: yAxisUnit
          }
        },
        legend: {
          layout: 'vertical',
          align: 'right',
          verticalAlign: 'middle',
          fontWeight: '300',
          borderWidth: 0
        },
        exporting: {
          sourceWidth: 1000,
          sourceHeight: 400,
          chartOptions:{
            title:{
              text:title
            },
            subtitle:{
              text:exportName
            }
          },
          buttons: {
            contextButton: {
              menuItems: [{
                text: 'Download as JPEG',
                onclick: function () {
                  this.exportChart({
                    type: 'image/jpeg',
                    filename: title
                  });
                }
              }, {
                text: 'Download as PDF',
                onclick: function () {
                  this.exportChart({
                    type: 'application/pdf',
                    filename: title
                  });
                },
                separator: false
              }]
            }
          }
        },
        series: [{
          type: 'arearange',
          showInLegend: false,
          name: "fillArea",
          data: data.area.map(function(x) {return x.value;}),
          fillColor: '#e1eff7'
        },
          {
            name: 'Top ' + data.top_quantile + '%' ,
            data: data.top.map(function(x) {return x.value;}),
            color: "#7add75"
          },
          {
            name: title,
            data: data.company.map(function(x) {return x.value;}),
            color: "#306581"
          },
          {
            name: 'Bottom ' + data.bottom_quantile + '%',
            data: data.bottom.map(function(x) {return x.value;}),
            color: "#e27f51"
          }],
        navigation: {
          menuItemStyle: {
            color: '#999999',
            fontSize: '13px',
            marginTop: '7px',
            fontWeight: '300'
          },
          menuItemHoverStyle: {
            background: 'none',
            color: '#54a3d8'
          },
          menuStyle: {
            border: '1px solid #A0A0A0',
            borderRadius: '4px',
            marginTop: '5px',
            background: '#FFFFFF'
          }
        },
        plotOptions: {
          line: {
            marker: {
              enabled: false
            }
          }
        },
        tooltip: {
          formatter: function (){
            if (this.series.name == "fillArea"){
              return false;
            } else {
              return "<p>"+ this.x +'</p><br/>'+
                "<p>" + this.series.name + ": </p>" + "<p><b>" + this.y + "</b></p>";
            }
          },
          // borderColor: "#999999",
          // backgroundColor: "#F2F2F2",
          // borderWidth: 1,
          style : {
            color: '#333333',
            fontSize: '14px !important',
            padding: '8px'
          }

        }
      };
    }

  }

})();