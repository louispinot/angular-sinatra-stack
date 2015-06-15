(function () {
  //'use strict';

  angular.module('compass')
    .directive('chart', [chartDirective]);

  function chartDirective() {
    return {
      restrict: 'E',
      template: '<div id="perf-charts"></div>',
      scope: {
        chartData: "=value",
        chartObj: "=?"
      },
      replace: true,
      link: function ($scope, $element, $attrs) {

        $scope.$watch('chartData', function(value) {
          if (!value)
            return;

          // use default values if nothing is specified in the given settings
          $scope.chartData.chart.renderTo = $scope.chartData.chart.renderTo || $element[0];
          if ($attrs.type)
            $scope.chartData.chart.type = $scope.chartData.chart.type || $attrs.type;
          if ($attrs.height)
            $scope.chartData.chart.height = $scope.chartData.chart.height || $attrs.height;
          if ($attrs.width)
            $scope.chartData.chart.width = $scope.chartData.chart.type || $attrs.width;

          $scope.chartObj = new Highcharts.Chart($scope.chartData);
        });
      }
    };
  }

})();



