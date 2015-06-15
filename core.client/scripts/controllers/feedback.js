(function () {
  'use strict';

  angular.module('compass').controller('FeedbackCtrl', ['$resource', '$scope', '$location', 'alertService', feedback]);

  function feedback ($resource, $scope, $location, alertService) {
    $scope.sendFeedback = sendFeedback;
    $scope.cancel = cancel;

    function sendFeedback() {
      var feedbackResource = $resource('feedback/submit');
      return feedbackResource.save($scope.model).$promise
        .then(function() {
          alertService.add({
            type: 'info',
            msg: 'Your feedback has ben sent.',
            redirects: 0
          });
        });
    }

    function cancel () {
      $location.path('/');
    }
  }

})();