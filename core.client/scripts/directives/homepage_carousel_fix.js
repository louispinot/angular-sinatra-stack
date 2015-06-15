// A compatibility issue between angular-ui and ngAnimate caused the carousel on the front page to break.
// Specifically the slide changed exactly once and stopped at the second one.

// The issue was tracked on this page:
// https://github.com/angular-ui/bootstrap/issues/1350

// This fix was in a comment, look for : "whitehat101 commented on May 28, 2014"


angular.module('compass').directive('disableNgAnimate', ['$animate', function($animate) {
  return {
    restrict: 'A',
    link: function(scope, element) {
      $animate.enabled(false, element);
    }
  };
}]);