(function () {
  'use strict';

  angular.module('compass').controller('marketingInputCtrl', ['$scope', "$resource", "$modalInstance", "marketingResourcesSvc", marketingInput]);

  function marketingInput ($scope, $resource, $modalInstance, marketingResourcesSvc) {
    var manualMetricsResource = $resource('manual_metrics');
    $scope.saveMetrics = saveMetrics;
    $scope.getMetrics = getMetrics;
    $scope.total = total;
    $scope.displayName = marketingResourcesSvc.displayName;
    $scope.newMetric = "";
    $scope.editing = false;
    $scope.createRow = createRow;
    $scope.newRow = newRow;
    $scope.removeRow = removeRow;
    $scope.hover = hover;
    $scope.closeModal = closeModal;

    $scope.tooltip = marketingResourcesSvc.tooltip;


    function closeModal() {
      $modalInstance.close();
    }

    function hover(type, row){
      if (type == "in") {
        row.highlight = true;
      } else if (type == "out") {
        row.highlight = false;
      }
    }

    function removeRow(row) {
      row.remove = true;
    }

    function newRow(){
      $scope.editing = true;
    }

    function createRow() {

      if ($scope.newMetric === "") {
        $scope.editing = false;
        return;
      }
      var metricHash = {name: $scope.newMetric, data: [], custom: true};
      angular.forEach($scope.months, function (month){
        metricHash.data.push({month: month, value: null});
      });
      $scope.rows.push(metricHash);
      $scope.newMetric = "";
      $scope.editing = false;

    } // createRow

    getMetrics();

    function getMetrics() {
      // TO DO: this methid also gets called when usr presses "cancel".
      // In that case there should be a flash message to tell the user that his changes have been cancelled
      manualMetricsResource.get().$promise
        .then(function(response) {
          $scope.rows = response.manual_metrics;
          $scope.months = response.months;
        });
    }

    function saveMetrics() {
      manualMetricsResource.save($scope.rows).$promise
        .then(function(response) {
           $modalInstance.close();
        });
    }

    function total(rows) {
      // this method computes the sum of the values in the provided rows for each month.
      // It can handle both nested and non nested rows so it is used both for the grand total and for the "online ads" sub-total
      var sumData = {};
      angular.forEach(rows, function(row){
        if (row.nested) {
          var subTotal = total(row.nested);
          angular.forEach(subTotal, function(monthlyValue, month){
            if (sumData[month]) {
              sumData[month] += monthlyValue;
            } else {
              sumData[month] = monthlyValue;
            }
          });
        } else {
          angular.forEach(row.data, function(dataHash){
            var month = dataHash.month;
            var value = dataHash.value;
            if (sumData[month]) {
              sumData[month] += value;
            } else {
              sumData[month] = value;
            }
          });
        }
      });
      return sumData;
    } // total

  } // marketingInput




})();