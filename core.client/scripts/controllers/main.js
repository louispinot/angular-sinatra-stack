(function () {
  'use strict';

  angular.module('habitac').controller('mainCtrl', ['$scope', main]);

  function main ($scope) {
    $scope.test = "View is talking to controller!"
  }

})();