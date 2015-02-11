'use strict'

class Controllers.MyProfileController extends Controllers.BaseController
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
    for item in $rootScope.achievements
      for item2 in $rootScope.userData.achievements
        if item.id == item2.pk
          item.active = true

    $rootScope.$watch('userData', ()->
      for item in $rootScope.achievements
        for item2 in $rootScope.userData.achievements
          if item.id == item2.pk
            item.active = true
    )

    $rootScope.profileCount = 0

app.controller 'myProfileCtrl', [
  '$scope'
  '$http'
  '$filter'
  '$timeout'
  '$location'
  '$baseUrl'
  '$rootScope'
  ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope) ->
    new Controllers.MyProfileController($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope)
]