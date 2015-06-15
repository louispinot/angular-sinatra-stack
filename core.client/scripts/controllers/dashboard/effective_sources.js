(function () {
  angular.module('compass').controller('EffectiveSourcesCtrl', ['$scope', '$resource', "$window", "$interval", "userService", effective]);

  function effective($scope, $resource, $window, $interval, userService) {
    var user = userService.getCurrentUser();
    var effectiveResource = $resource('dashboard/effective_sources');
    var sources = ["Email", "Direct", "Display", "Organic", "Paid", "Referral", "Social"];
    $scope.activeLink = "All";
    $scope.graph = graph;
    $scope.googleConnected = true;
    $scope.lifestageCompleted = user.lifestage_state == 'complete';
    $scope.hasData = {all: true, organic: false, direct: false, email: false, referral: false};
    $scope.enoughData = false;

    getEffectiveSources();

    $scope.$on('surveyComplete', function(){
      $scope.lifestageCompleted = userService.getCurrentUser().lifestage_state == 'complete';
    });

    var refresh = $interval(refreshEffectiveSources, 15000, 3);

    $scope.$on('$destroy', function() {
      stopRefresh();
    });

    function stopRefresh() {
      if (angular.isDefined(refresh)) {
        $interval.cancel(refresh);
        refresh = undefined;
      }
    }

    function refreshEffectiveSources() {
      if ($scope.enoughData) {
        return;
      }
      getEffectiveSources();
    }

    function getEffectiveSources() {
      effectiveResource.get().$promise
        .then(function(response) {
          $scope.dashboard = response;
          $scope.googleConnected = response.google_connected;

          var dataCount = 0;
          angular.forEach(sources, function (source){
            if($scope.dashboard[source.toLowerCase()] && $scope.dashboard[source.toLowerCase()].value.length !== 0){
              $scope.hasData[source.toLowerCase()] = true;
              dataCount++;
            } else {
              $scope.hasData[source.toLowerCase()] = false;
            }
          });
          $scope.enoughData = ( dataCount > 0 ? true : false );
          graphFormat();
          overviewGraphData($scope.dashboard);
        });
    }


    function graph(source){
      // the graphs all share the same formatting options, these are set in graphFormat()
      // they only differ by their series, set by either overviewGraphData() or drillDownGraphData()
      graphFormat();
      if (source == 'All') {
        overviewGraphData($scope.dashboard);
        $scope.activeLink = "All";
      } else {
        drillDownGraphData($scope.dashboard[source.toLowerCase()], source);
        $scope.activeLink = source;
      }
    }

    function overviewGraphData(data){
      // this sets the graph to show all different types of traffic sources together, whitouht their corresponding benchmarks
      $scope.chartData.series = [];

      var colors = {email: '#f0cc43', direct: '#e55512', display: 'rgba(223, 83, 83, .5)', organic: '#58c153', paid: 'rgba(223, 83, 83, .5)', referral: '#3A97C8', social: 'rgba(223, 83, 83, .5)'};

      angular.forEach(sources, function (source) {
        var value = data[source.toLowerCase()] ? data[source.toLowerCase()].value : [];
        $scope.chartData.series.push({
          name: source,
          color: colors[source.toLowerCase()],
          data: [value],
          dataLabels: {
            x: 6,
            y: 13,
            align: 'left'
          }
        });
      });
    }

    function drillDownGraphData(data, seriesName){
      // this function sets the graph to show one type of traffic sources with it's corresponding top and bottom benchmark
      var colors = {email: '#f0cc43', direct: '#e55512', display: 'rgba(223, 83, 83, .5)', organic: '#58c153', paid: 'rgba(223, 83, 83, .5)', referral: '#3A97C8', social: 'rgba(223, 83, 83, .5)'};
      $scope.chartData.series = [{
        name: seriesName,
        color: colors[seriesName.toLowerCase()],
        data: [data.value],
        dataLabels: {
          x: 6,
          y: 13,
          align: 'left'
        }
      }, {
        name: "Lower Quantile",
        data: [data.bottom],
        marker: {
          //the image url has to be accessible by the highcharts export server for the markers to appear when a user exports the graph
          symbol: "url(https://s3-us-west-2.amazonaws.com/compasscore/public_resources/traffic_sources_bottom.png)"        },
        dataLabels: {
          x: 6,
          y: 10,
          align: 'left'
        }
      }, {
        name: "Upper Quantile",
        data: [data.top],
        marker: {
          //the image url has to be accessible by the highcharts export server for the markers to appear when a user exports the graph
          symbol: "url(https://s3-us-west-2.amazonaws.com/compasscore/public_resources/traffic_sources_top.png)"
        },
        dataLabels: {
          x: 0,
          y: -13,
          align: 'right'
        }
      }]; // $scope.chartData.series
    }

    function graphFormat(){
      $scope.chartData = {
        chart: {
          style: {
            fontFamily: 'Open Sans'
          },
          type: 'scatter',
          zoomType: 'xy'
        },
        title: {
          text: ''
        },
        xAxis: {
          gridLineWidth: 0,
          min: 0,
          max: 100,
          maxPadding:0.06,
          title: {
            enabled: true,
            text: '% of traffic'
          },
          startOnTick: true,
          endOnTick: true,
          showLastLabel: true
        },
        yAxis: {
          maxPadding:0.1,
          gridLineWidth: 0,
          min: 0,
          max: 100,
          minorGridLineWidth: 0,
          title: {
            text: 'Quality of Traffic'
          }
        },
        legend: {
          enabled:false
        },
        plotOptions: {
          series: {
            marker: {
              symbol: 'circle'
            }
          },
          scatter: {
            dataLabels: {
              enabled:true,
              overflow: "none",
              crop: false,
              formatter: function(){
                return "<span>" + this.series.name + "</span>";
              },
              style: {
                fontSize: '16px'
              }
            },
            marker: {
              radius: 5,
              states: {
                hover: {
                  enabled: true,
                  lineColor: 'rgb(100,100,100)'
                }
              }
            },
            states: {
              hover: {
                marker: {
                  enabled: false
                }
              }
            }
          }
        },
        tooltip: {
          headerFormat: '<b>{series.name}</b><br>',
          pointFormat: 'Share of traffic: {point.x}%,<br>Quality of traffic: {point.y}%',
          // borderColor: "#999999",
          // backgroundColor: "#F2F2F2",
          // borderWidth: 1,
          style : {
            color: '#333333',
            fontSize: '14px !important',
            fontFamily: "'Open Sans', sans-serif",
            padding: '8px'
          }
        },
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
        exporting: {
          sourceWidth: 1000,
          sourceHeight: 400,
          chartOptions:{
            title:{
              text:'Web Traffic Sources Graph'
            }
          },
          buttons: {
            contextButton: {
              menuItems: [{
                text: 'Download as JPEG',
                onclick: function () {
                  this.exportChart({
                    type: 'image/jpeg',
                    filename: "Traffic sources"
                  });
                }
              }, {
                text: 'Download as PDF',
                onclick: function () {
                  this.exportChart({
                    type: 'application/pdf',
                    filename: "Traffic sources"
                  });
                },
                separator: false
              }]
            }
          }
        }
      }; // $scope.chartData
    } // graphFormat()

  }
})();
