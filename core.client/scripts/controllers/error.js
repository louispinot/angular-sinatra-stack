(function () {
  'use strict';

  angular.module('compass').controller('ErrorCtrl', ['$scope', 'errorService', error]);

  function error ($scope, errorService) {
    $scope.statusCode = errorService.getErrorCode();
  }

})();