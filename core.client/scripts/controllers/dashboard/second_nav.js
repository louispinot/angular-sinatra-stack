(function () {
  'use strict';

  angular.module('compass').controller('secondNavCtrl', ['$scope', 'userService', secondNav]);

  function secondNav($scope, userService) {
    $scope.company = getData();

    function getData() {
      var user = userService.getCurrentUser();
      return {peerGroup: user.peergroup,
              segment: user.company_segment,
              name: user.company_name
             };
    }
  }

})();
