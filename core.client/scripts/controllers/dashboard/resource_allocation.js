(function (){
  angular.module('compass').controller('ResourceAllocationCtrl', ['$scope', '$resource', "$modal", "marketingResourcesSvc", resource]);

  function resource($scope, $resource, $modal, marketingResourcesSvc) {
    var resourceAllocation = $resource('dashboard/resource_allocation');
    $scope.modal = modal;

    getData();

    function getData() {
      resourceAllocation.get().$promise.then(function(response) {
        $scope.data = response;
        $scope.hasData = ($scope.data.values.length !== 0 );
        angular.forEach($scope.data.values, function(series){
          series.name = marketingResourcesSvc.displayName(series.name);
        });
        mapGraph($scope.data);
      });
    }

    function modal() {

      var modalInstance = $modal.open({
            templateUrl: 'views/mkt_data_input.html',
            controller: "marketingInputCtrl",
            size: 'lg',
            backdrop: 'static' // prevents closing the modal when clicking out of it (mitigates risk of losing all the entered non-saved data for users who would click out of the modal by mistake)
          });
      modalInstance.result.then(function(){
        getData();
      });
    }

    function mapGraph(data) {
      $scope.chartData = {
        chart: {
          style: {
            fontFamily: 'Open Sans'
          },
          type: 'area'
        },
        title: {
          text: ''
        },
        series: data.values,
        xAxis: {
          gridLineWidth: 0,
          categories: data.months,
          tickmarkPlacement: 'on',
          title: {
            enabled: false
          }
        },
        yAxis: {
          minorGridLineWidth: 0,
          title: {
            text: 'Percent'
          }
        },
        tooltip: {
          shared: true,
          useHTML: true,
          formatter: function(){
            var point = this;
            var tooltip = '<span style="font-size: 14px; font-weight:400">'+ point.x +'</span><br/><br/>';
            tooltip += '<table style="text-align:center"><thead><tr>'+'<th style="padding-right:3px">Category</th>'+'<th style="padding-right:3px">&nbsp % of total &nbsp</th>'+'<th style="padding-right:3px">&nbspValue</th></tr></thead>'+'<tbody>';
            angular.forEach(data.values, function(metric){
              var monthIndex = data.months.indexOf(point.x);
              if (metric.data[monthIndex] > 0) {
                var percentage = metric.data[monthIndex] / data.monthly_totals[point.x] * 100;
                var line = "<tr>" + "<th style='padding-right:10px; font-weight:400'>"+ metric.name +"</th>" + "<td>"+ percentage.toFixed(1) +"%</td>"+ "<td>"+ metric.data[monthIndex] +"</td>" + "</tr>";
                tooltip += line;
              }
            });
            return tooltip + "</tbody></table>";
          }
        },
        plotOptions: {
          area: {
            stacking: 'percent',
            lineColor: '#ffffff',
            lineWidth: 1,
            marker: {
              lineWidth: 1,
              lineColor: '#ffffff'
            }
          }
        },
        legend: {
          itemStyle: {
            fontWeight: "400"
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
              text:'Marketing Resource Allocation Graph'
            }
          },
          buttons: {
            contextButton: {
              menuItems: [{
                text: 'Download as JPEG',
                onclick: function () {
                  this.exportChart({
                    type: 'image/jpeg',
                    filename: "Marketing Resource Allocation"
                  });
                }
              }, {
                text: 'Download as PDF',
                onclick: function () {
                  this.exportChart({
                    type: 'application/pdf',
                    filename: "Marketing Resource Allocation"
                  });
                },
                separator: false
              }]
            }
          }
        }
      }; // $scope.chartData
    } // mapGraph

  }
})();