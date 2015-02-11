'use strict'

class Controllers.BaseController
  @$inject = [
    '$scope', '$rootScope'
  ]

  constructor: ($scope, $rootScope) ->
    if !$rootScope.pageLoaded
      if $rootScope.userData
        $scope.goToMyProfile('panel')

        $rootScope.authPageLoaded = true
      else
        $scope.goToHowToPlay('panel')

      $rootScope.pageLoaded = true
    else if !$rootScope.authPageLoaded && $scope.userData
      $scope.goToMyProfile('panel')

      $rootScope.authPageLoaded = true

app.controller 'parentCtrl', [
  '$scope', '$rootScope'
  ($scope, $rootScope) ->
    new Controllers.BaseController($scope, $rootScope)
]
