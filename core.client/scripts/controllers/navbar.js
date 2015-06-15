(function () {

  angular.module('compass').controller('NavbarCtrl', ['$scope', '$location', 'loginService', 'userService', navbar]);

  function navbar ($scope, $location, loginService, userService) {

    $scope.logout = logout;
    $scope.currentPage = currentPage;
    $scope.logoRoute = logoRoute;

    function logoRoute(){
      // in the survey navbar
      var user = userService.getCurrentUser();
      if (user.lifestage_state) {
        // user only has a lifestage_state if he's already answered survey and is taking it again
        // this makes the logo a clickable link to get back to the dashboard and drop retaking the survey
        user.survey_state = "clustering_complete";
        // reset survey_state to "clustering complete" to prevent bugs
        userService.setUser(user);
        $location.path('/dashboard');
      }
    }

    function currentPage(page) {
      // in the application layout
      if ($location.path() == page){
        return true;
      }
    }

    function logout() {
      loginService.logout();
      $location.path('/');
    }

  }

})();

