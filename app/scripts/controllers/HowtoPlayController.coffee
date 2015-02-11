'use strict'

class Controllers.HowtoPlayController extends Controllers.BaseController
  @$inject = [
    '$scope'
    '$http'
    '$filter'
    '$timeout'
    '$location'
    '$baseUrl'
    '$rootScope'
  ]

  constructor: ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope) ->
    super($scope, $rootScope)
    $scope.changeType = (type)->
      $scope.selectedType = type
      if $rootScope[type]
        $timeout ->
          $rootScope[type].reInit()
        , 100

      $scope.paginator = type.length > 1

    if !$scope.userData then $rootScope.showMenu = undefined

    $scope.howtoData = {}

    $scope.options = {}

    for key of $rootScope.howToPlayData
      opt_key = key.replace(" ", '-')
      $scope.options[key] = opt_key
      $scope.howtoData[opt_key] = $rootScope.howToPlayData[key]

    $scope.changeType $scope.options['Overview']

app.controller 'howToPlayCtrl', [
  '$scope'
  '$http'
  '$filter'
  '$timeout'
  '$location'
  '$baseUrl'
  '$rootScope'
  ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope) ->
    new Controllers.HowtoPlayController($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope)

]
