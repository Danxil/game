'use strict'

class Controllers.InviteFriendsController extends Controllers.BaseController
  @$inject = [
    '$scope'
    '$http'
    '$filter'
    '$timeout'
    '$location'
    '$baseUrl'
    '$rootScope'
    'Constants'
  ]

  constructor: ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, Constants) ->
    super($scope, $rootScope)
    $scope.SOCIALS =
    [
      'fb'
      'tw'
      'in'
      'ma'
    ]

    $scope.shareText = 'Go to link!'

    $scope.chooseSocial = (social)->
      $scope.selectedSocial = social
      $scope.shareText = Constants.getSharingTemplate(social, $scope.userData.refLink)

    $scope.sharing = ->
      text = Constants.prepareMessage($scope.selectedSocial, $scope.shareText)
      share_dialog = window.utils.get_share_dialog 'i'
      share_dialog $scope.selectedSocial

    $scope.chooseSocial $scope.SOCIALS[0]

app.controller 'inviteFriendsCtrl', [
  '$scope'
  '$http'
  '$filter'
  '$timeout'
  '$location'
  '$baseUrl'
  '$rootScope'
  '$controller'
  'Constants'
  ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $controller, Constants) ->
    new Controllers.InviteFriendsController($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, Constants)
]