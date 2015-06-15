(function () {
  'use strict';

  angular.module('compass').controller('trafficLightsCtrl', ['$scope', "$parse", "$resource", trafficLights]);

  function trafficLights($scope, $parse, $resource) {

    $scope.focusOn = focusOn;
    $scope.focusMetric = "returning_visitors";

    getData();

    function getData() {
      var metricResource = $resource('traffic_lights');
        metricResource.get().$promise
        .then(function(response){
          for(var metric in response.data) {
            // sets the response data on the scope with dyamic naming
            $parse(metric).assign($scope, response.data[metric]);
          }
        })
        .catch(function(response){
          return;
        });

    }

    function focusOn(metric){
      $scope.focusMetric = metric;
    }

  }

})();
