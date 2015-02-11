'use strict'

class Controllers.FirstLoadController
  @$inject = [
    '$scope',
    '$http',
    '$filter',
    '$timeout',
    '$location',
    'ipCookie'
    '$cookies'
    '$rootScope'
    '$window'
    '$baseUrl'
    '$interval'
    '$orientation'
    '$state'
    'socket'
    '$document'
    '$howToService'
    '$q']

  constructor: ($scope, $http, $filter, $timeout, $location, $ipCookie, $cookies, $rootScope, $window, $baseUrl, $interval, $orientation, $state, socket, $document, $howToService, $q, $gameService) ->

    $http.get '/api/achievements/'
    .success (data)->
      for item in data
        item.active = false

      $rootScope.achievements = data

    $rootScope.totalCount = $rootScope.pedingChallengesCount = $rootScope.leaderBoardChanged = $rootScope.profileCount = 0

    $rootScope.offline = false
    $rootScope.gameInProgress = false

    $rootScope.offlineHandler = (after_game=true) ->
      $rootScope.afterGame = after_game
      if !$rootScope.gameInProgress
        $rootScope.offline = true

        if after_game
          message = switch $rootScope.choosenOpponentType
            when "computer" || "opponent" then "Don't worry though, your play performance has been saved and your results will be available as soon as you're back online"
            when "challenge" then "Don't worry though, your play performance has been saved and your challenge will be sent as soon as you're back online"
        else
          message = "This is a web-based game, but don't worry, you can continue once you're back online"

        $rootScope.offlineMessage = message
      else
        localStorage.setItem('lastResult', true)


    Offline.on("down", (e) ->
      $rootScope.offlineHandler(false)
      $rootScope.$apply()
    )

    Offline.on("up", (e) ->
      reqData = window.utils.request if window.utils.request?
      if reqData
        $http.post(reqData.url, reqData.data).success (data)->
          localStorage.removeItem('saveGame')
          reqData.callback data, reqData.data.won

          delete $rootScope.choosenOpponentType
          delete $rootScope.choosenOpponent
          delete $rootScope.choosenChallenger
          delete $rootScope.gameProcess
          delete $rootScope.choosenCategory
          delete $rootScope.choosenGame
          $rootScope.gameInProgress = false
      $rootScope.offline = false
      $rootScope.$apply()
    )

    setInterval(()->
      Offline.check()
    20000)

    $rootScope.$watch('pedingChallengesCount + leaderBoardChanged + profileCount', ()->
      $rootScope.updateTotalCount()
    )

    $rootScope.updateTotalCount = ()->
      $rootScope.totalCount = $rootScope.pedingChallengesCount + $rootScope.leaderBoardChanged + $rootScope.profileCount
      $rootScope.totalCount

    $scope.postGameResult = (selectedSocial, data)->
      result_type = if data.badge? then 'b' else 'w'
      share_dialog = window.utils.get_share_dialog result_type
      share_dialog selectedSocial

    $scope.openNote = (url)->
      if $rootScope.gameProcess then return

      if $rootScope.userData
        $scope.currentUrl = $location.path()
        $location.path("/" + $orientation.getStateTarget() + "/note/#{url}")
      else
        $http.get('/api/note/', params:
          url: url
        ).success (data)->
          $scope.note = data

    $scope.shareLink = (social, link = $baseUrl, text = '')->
      share_dialog = window.utils.get_share_dialog 'r'
      share_dialog social

    $scope.closeNote = ->
      delete $scope.note

    $scope.chooseOpponent = (profile)->
      if $rootScope.gameProcess || ($rootScope.choosenOpponent && $rootScope.choosenOpponent.pk == profile.pk) then return

      if profile.pk == $scope.userData.pk
        $rootScope.invalidOpponent = profile

        return $scope.goToInvalidOpponent()

      if $scope.choosenGame != undefined
        $gameService.checkUserAllow profile.pk, $scope.choosenGame.pk
        .then (result)->
          data = result.data

          if !data.allow
            $rootScope.invalidOpponent = profile
            if data.reason == "invited"
              $rootScope.invalidOpponentGameName = $scope.choosenGame.title

            return $scope.goToInvalidOpponent()

          $rootScope.choosenOpponent = profile

          $scope.goToGameLoading()
      else
        $rootScope.choosenOpponent = profile

        $scope.goToChooseCategory()

    $scope.newGame = ->
      if $rootScope.gameProcess then return

      delete $rootScope.choosenOpponent
      delete $rootScope.choosenChallenger
      delete $rootScope.gameProcess
      delete $rootScope.choosenCategory
      delete $rootScope.choosenGame

      $scope.goToChooseCategory()

    if $location.url() == '/' || !$location.url()
      if $ipCookie('first') is undefined
        $scope.goToMain()
      else
        $scope.goToLogged()

    saveGame = JSON.parse(localStorage.getItem('saveGame'))

    if saveGame
      $http.post(saveGame.url, saveGame.data).success (data)->
        localStorage.removeItem('saveGame')

        $rootScope.finishGameObj = saveGame.data

        $timeout ->
          eval '(' + saveGame.callback + ')(' + JSON.stringify(data) + ',' + saveGame.data.won + ')'
        , 1000

    $rootScope.howToPlayData = null
    $q.when($howToService.getMainData()).then (data)->
      $rootScope.howToPlayData = data

    $rootScope.getNumber = (number) ->
      s = ["th","st","nd","rd"]
      v = number % 100
      number + (s[(v-20)%10] || s[v] || s[0])

app.controller 'firstLoadCtrl', [
  '$scope'
  '$http'
  '$filter'
  '$timeout'
  '$location'
  'ipCookie'
  '$cookies'
  '$rootScope'
  '$window'
  '$baseUrl'
  '$interval'
  '$orientation'
  '$state'
  'socket'
  '$document'
  '$howToService'
  '$q'
  '$gameService'
  ($scope, $http, $filter, $timeout, $location, $ipCookie, $cookies, $rootScope, $window, $baseUrl, $interval, $orientation, $state, socket, $document, $howToService, $q, $gameService) ->
    new Controllers.FirstLoadController($scope, $http, $filter, $timeout, $location, $ipCookie, $cookies, $rootScope, $window, $baseUrl, $interval, $orientation, $state, socket, $document, $howToService, $q, $gameService)
]
