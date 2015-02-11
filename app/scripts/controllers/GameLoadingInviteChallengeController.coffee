'use strict'

class Controllers.GameLoadingInviteChallengeController extends Controllers.GameLoadingController
  @$inject = [
    '$scope'
    '$http'
    '$filter'
    '$timeout'
    '$location'
    '$baseUrl'
    '$rootScope'
    '$randomValue'
    '$controller'
    '$stateParams'
    '$gameService'
    '$q'
    'challenge'
    'visualInstruction'
  ]

  constructor: ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $randomValue, $controller, $stateParams, $gameService, $q, challenge, visualInstruction) ->
    challenge = challenge[0]

    $rootScope.choosenChallenger =
      avatar: challenge.challenger_image
      username: challenge.challenger_name
      correct_answers: challenge.correct_answers
      time: challenge.game_time
      challenge_id: challenge.pk

    $rootScope.choosenGame =
      pk: challenge.game_pk
      icon: challenge.game_icon
      title: challenge.game_title
      points: challenge.game_points
      game_type: challenge.game_type
      first_play: challenge.first_play
      asset_title: challenge.game_asset_title
      asset_link: challenge.game_asset_link

    super($scope, $http, $filter, $timeout, $interval, $location, $baseUrl, $rootScope, $randomValue, $gameService, $q, visualInstruction)

app.controller 'gameLoadingInviteChallengeCtrl', [
  '$scope'
  '$http'
  '$filter'
  '$timeout'
  '$location'
  '$baseUrl'
  '$rootScope'
  '$randomValue'
  '$controller'
  '$stateParams'
  '$gameService'
  '$q'
  'challenge'
  'visualInstruction'
  ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $randomValue, $controller, $stateParams, $gameService, $q, challenge, visualInstruction) ->
    new Controllers.GameLoadingInviteChallengeController($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $randomValue, $controller, $stateParams, $gameService, $q, challenge, visualInstruction)
]
