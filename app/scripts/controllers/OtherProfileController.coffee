'use strict'

class Controllers.OtherProfileController extends Controllers.BaseController
  @$inject = [
    '$scope'
    '$http'
    '$filter'
    '$timeout'
    '$location'
    '$baseUrl'
    '$rootScope'
    'data'
  ]

  constructor: ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, data) ->
    super($scope, $rootScope)

    $scope.otherProfile = data

    $scope.goToMyProfile() if $scope.userData.pk == $scope.otherProfile.pk

    $http.get '/api/achievements/'
    .success (data)->
      $scope.achievements = data

    $scope.otherProfile.achievements = $scope.otherProfile.achievements || []

app.controller 'otherProfileCtrl', [
  '$scope'
  '$http'
  '$filter'
  '$timeout'
  '$location'
  '$baseUrl'
  '$rootScope'
  'data'
  ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, data) ->
    new Controllers.OtherProfileController($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, data)
]