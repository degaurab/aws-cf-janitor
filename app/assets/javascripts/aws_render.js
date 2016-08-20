angular.module('awsExtractor', [])
  .controller('AWSExtractor', function($scope, $http) {

    $scope.deleteList = [];

    $scope.deleteAll = function () {

      for (i = 0; i < $scope.deleteList.length; i++) {
        $http({
          method: 'DELETE',
          url: '/allocation_changes/' + $scope.deleteList[i]
        }).then(function successCallback(response){
        }, function errorCallback(response) {
        });
      }
      alert("Allocation delete successful!");
      location.reload();
    };

    $scope.updateDeleteList = function (allocation_id, checked) {
      if (checked) {
        $scope.deleteList.push(allocation_id);
      } else {
        var index = $scope.deleteList.indexOf(allocation_id);
        $scope.deleteList.splice(index, 1);
      }
      $scope.deleteSelected = $scope.deleteList.length !== 0;
    }

    $scope.deleteSelected = $scope.deleteList.length !== 0;

  });
