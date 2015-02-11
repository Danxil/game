'use strict'

class Controllers.NoteController extends Controllers.BaseController
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
    $scope.showMenu = $rootScope.userData != undefined
    $http.get('/api/note/', params:
        url: $rootScope.choosenNote
      ).success (data)->
        $scope.note = data

app.controller "noteCtrl", [
  '$scope'
  '$http'
  '$filter'
  '$timeout'
  '$location'
  '$baseUrl'
  '$rootScope'
  '$stateParams'
  '$controller'
  ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $stateParams, $controller) ->
    new Controllers.NoteController($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $stateParams, $controller)
]