'use strict'

class Controllers.GameLoadingController extends Controllers.BaseController
  @$inject = [
    '$scope'
    '$http'
    '$filter'
    '$timeout'
    '$interval'
    '$location'
    '$baseUrl'
    '$rootScope'
    '$randomValue'
    '$gameService'
    '$q'
    'visualInstruction'
  ]

  constructor: ($scope, $http, $filter, $timeout, $interval, $location, $baseUrl, $rootScope, $randomValue, $gameService, $q, visualInstruction) ->
    super($scope, $rootScope)
    $scope.startGame = ->
      if !$rootScope.gameData || !$rootScope.opponent
        return

      $rootScope.asset_title = $rootScope.choosenGame.asset_title
      $rootScope.asset_link = $rootScope.choosenGame.asset_link

      switch $rootScope.choosenGame.game_type
        when 0
          $scope.goToGameProcessTrivia()
        when 1
          $scope.goToGameProcessWord()
        when 2
          $scope.goToGameProcessPriority()

    $rootScope.opponentType = switch
      when !$rootScope.choosenOpponent && !$rootScope.choosenChallenger then 'computer'
      when $rootScope.choosenOpponent then 'challenge'
      when $rootScope.choosenChallenger then 'opponent'

    $scope.title = 'Good luck!'

    $scope.visualInstruction = visualInstruction.image
    instructionTimeout = (_.flipC $timeout) if $rootScope.choosenGame.first_play then visualInstruction.timeout else 3000

    delete $rootScope.gameData
    delete $rootScope.opponent

    questionParams = {}

    $scope.generateAvatar = (avatars) ->
      avatar = ''
      avatar_length = avatars.length - 1
      while !avatar || avatar == $rootScope.userData.avatar
        avatar = avatars[$randomValue(0, avatar_length)]
      avatar

    $scope.message = false
    switch $scope.opponentType
      when 'computer'
        $http.get('/api/avatar/').success (data)->
          avatar = $scope.generateAvatar(data)
          $rootScope.opponent =
            avatar: avatar.image
            avatar_bg: avatar.bg
      when 'challenge'
        $rootScope.opponent = $rootScope.choosenOpponent
        $scope.message = true
      when 'opponent'
        $rootScope.opponent = $rootScope.choosenChallenger

        questionParams.challenge = $rootScope.choosenChallenger.challenge_id

    questions = $gameService.getQuestions($rootScope.choosenGame.pk, questionParams)

    $q.when(questions).then (result)->
      instructionTimeout ->
        $rootScope.gameData = result.data
        $scope.title = 'Ok, get ready'
        $scope.counter = 3
        countdown = (_.flip $interval) 1000, ->
          if $scope.counter then $scope.counter--
          if $scope.counter <= 0
            $interval.cancel countdown
            delete $scope.counter
            $scope.startGame()

app.controller 'gameLoadingCtrl', [
  '$scope'
  '$http'
  '$filter'
  '$timeout'
  '$interval'
  '$location'
  '$baseUrl'
  '$rootScope'
  '$randomValue'
  '$gameService'
  '$q'
  'visualInstruction'
  ($scope, $http, $filter, $timeout, $interval, $location, $baseUrl, $rootScope, $randomValue, $gameService, $q, visualInstruction) ->
    new Controllers.GameLoadingController($scope, $http, $filter, $timeout, $interval, $location, $baseUrl, $rootScope, $randomValue, $gameService, $q, visualInstruction)
]