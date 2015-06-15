(function () {
  'use strict';

  angular.module('habitac').factory('alertService', ['$rootScope', alert]);

  function alert ($rootScope) {

    var service = {};
    $rootScope.alerts = [];

    service.add = addAlert;
    service.clear = clearAlerts;

    function addAlert(options) {
      if($rootScope.alerts.map(function(x){return x.msg;}).indexOf(options.msg) === -1){
        $rootScope.alerts.push({
          type: options.type,
          msg: options.msg,
          header: options.header,
          region: options.region,
          redirects: options.redirects || 0
        });
      }
    }

    function clearAlerts () {
      $rootScope.alerts = $rootScope.alerts.filter(function (x) { return x.redirects > 0; })
        .map(function (x) { x.redirects = x.redirects - 1; return x;});
    }

    return service;
  }

})();