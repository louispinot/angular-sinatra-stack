(function () {
  'use strict';

  angular.module('compass').controller('FooterCtrl', ['$scope', '$location', footer]);

  function footer ($scope, $location) {
    $scope.showFooter = function() {
      return ['/dashboard'].indexOf($location.path ()) > -1;
    };
  }

})();