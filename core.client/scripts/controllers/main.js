(function(){
  angular.module('compass').controller('MainCtrl', ['$rootScope', "$scope", mainCtrl]);

  function mainCtrl($rootScope, $scope) {

    $rootScope.$on('$viewContentLoaded', function(){
      $rootScope.preventOverflow = false;
    });
  }
})();
