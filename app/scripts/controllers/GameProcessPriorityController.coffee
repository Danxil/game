'use strict'

class Controllers.GameProcessPriorityController extends Controllers.BaseController
  @$inject = [
    '$scope'
    '$http'
    '$filter'
    '$timeout'
    '$location'
    '$baseUrl'
    '$rootScope'
    '$interval'
  ]

  constructor: ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $interval) ->
    $rootScope.gameInProgress = true
    goToFinishGameFn = ->
      $scope.correctSortedHilight = true

      $scope.finishGame()

    cancelTimeLeftInterval = (player)->
      $interval.cancel _this.timeLeftInterval[player]

    $scope.checkAnswer = (result, player)->
      if $scope.correctAnswer[player] != undefined || ($scope.timeOver && $scope.timeOver[player])
        return;

      callback = (result)->
        if result
          gameData[player].correctAnswers++

          $scope.correctAnswer[player] = true

          if player == 'my'
            cancelTimeLeftInterval('opponent')

            goToFinishGameFn()
        else
          $scope.correctAnswer[player] = false

          if player == 'my'
            if $scope.numberStrike.my < $scope.STRIKES_COUNT - 1 && $scope.timeLeft[player] > 0
              $scope.strikeScreenShow = true
            else
              $scope.animateSortedActive = true

        if player == 'my'
          gameData.my.detailsQuestions[_this.pkQuestion][$scope.numberStrike[player]].response_time = TIME_FROM_ANSWER - $scope.timeLeft[player]
          gameData.my.detailsQuestions[_this.pkQuestion][$scope.numberStrike[player]].correct = $scope.correctAnswer[player]
          gameData.my.detailsQuestions[_this.pkQuestion][$scope.numberStrike[player]].answer = ''

      cancelTimeLeftInterval(player)

      switch typeof result
        when 'object'
          for item, i in result
            if item.order != i
              orderNotCorrect = true

              $scope.incorrectItemsCount[player]++

          if orderNotCorrect
            callback false
          else
            callback true
        when 'boolean'
          callback result

      if $scope.opponentType != 'challenge' && player == 'opponent' && $scope.correctAnswer[player] == false
        $timeout ->
          $scope.toNextStrike(player)
        , 2000

    $scope.toNextStrike = (player)->
      if !$scope.numberStrike then $scope.numberStrike = my: -1, opponent: -1

      $scope.numberStrike[player]++

      if $scope.numberStrike[player] > $scope.STRIKES_COUNT - 1 || ($scope.timeOver && $scope.timeOver[player])
        return

      if !$scope.correctAnswer then $scope.correctAnswer = {}
      if !$scope.timeLeft then $scope.timeLeft = {}
      if !$scope.timeLeft[player] then $scope.timeLeft[player] = TIME_FROM_ANSWER
      if !$scope.timeOver then $scope.timeOver = {}
      if !_this.timeLeftInterval then _this.timeLeftInterval = {}
      if !$scope.incorrectItemsCount then $scope.incorrectItemsCount = {}

      $scope.correctAnswer[player] = undefined

      $scope.incorrectItemsCount[player] = 0

      $scope.timeOver[player] = false

      $scope.progress.time[player] = (1 - (TIME_FROM_ANSWER - $scope.timeLeft[player]) / TIME_FROM_ANSWER) * 100

      switch player
        when 'my'
          if !gameData.my.detailsQuestions[_this.pkQuestion][$scope.numberStrike[player]]
            gameData.my.detailsQuestions[_this.pkQuestion][$scope.numberStrike[player]] = {}

          $scope.strikeScreenShow = false

          $scope.answers = []

          for value in $rootScope.gameData.question.answers
            $scope.answers.push value
        when 'opponent'
          $scope.opponentAnswer = $rootScope.gameData.comp_answer[$scope.numberStrike[player]]

      _this.timeLeftInterval[player] = $interval ->

        $scope.timeLeft[player]--

        $scope.progress.time[player] = (1 - (TIME_FROM_ANSWER - $scope.timeLeft[player]) / TIME_FROM_ANSWER) * 100

        gameData[player].time = TIME_FROM_ANSWER - $scope.timeLeft[player]

        if player == 'opponent' && $scope.opponentType != 'challenge' && TIME_FROM_ANSWER - $scope.timeLeft[player] >= $scope.opponentAnswer.time_response
          $scope.checkAnswer($scope.opponentAnswer.correct, 'opponent')

        if $scope.timeLeft[player] <= 0
          cancelTimeLeftInterval(player)

          $scope.checkAnswer(false, player)

          $scope.timeOver[player] = true
      , 1000

    $scope.finishGame = ->
      gameWon = (gameData.my.correctAnswers > gameData.opponent.correctAnswers) ||
      (gameData.my.correctAnswers > 0 && gameData.my.correctAnswers == gameData.opponent.correctAnswers && gameData.my.time < gameData.opponent.time)

      reqData = switch
        when $scope.opponentType == 'computer'
          url: '/api/game/'
          data:
            game: $rootScope.choosenGame.pk
            won: gameWon
            correct_answers: gameData.my.correctAnswers
            game_time: gameData.my.time
          callback: (data, gameWon)->
            $rootScope.gameResult = data
            $rootScope.gameResult.points = $rootScope.choosenGame.points

            switch gameWon
              when true
                if !data.achievements.length
                  $scope.goToGameWon()
                else
                  $scope.goToGameCongrats()
              when false
                $scope.goToGameLose1()


        when $scope.opponentType == 'challenge'
          url: '/api/challenge/'
          data:
            detail: gameData.my.detailsQuestions
            total:
              challenged: $rootScope.choosenOpponent.pk
              game: $rootScope.choosenGame.pk
              correct_answers: gameData.my.correctAnswers
              game_time: gameData.my.time
          callback: (data)->
            $scope.goToChallengeSent()

        when $scope.opponentType == 'opponent'
          url: '/api/challenge/'
          data:
            detail: gameData.my.detailsQuestions
            total:
              challenge_id: $rootScope.choosenChallenger.challenge_id
              correct_answers: gameData.my.correctAnswers
              game_time: gameData.my.time
              won: gameWon
          callback: (data, gameWon)->
            $rootScope.gameResult = data
            $rootScope.gameResult.points = $rootScope.choosenGame.points

            switch gameWon
              when true
                if !data.achievements.length
                  $scope.goToGameWon()
                else
                  $scope.goToGameCongrats()
              when false
                $scope.goToGameLose1()

      $rootScope.finishGameObj = reqData.data

      $http.post(reqData.url, $scope.finishGameObj).success (data)->
        $timeout ->
          reqData.callback data, gameWon

          delete $rootScope.choosenOpponent
          delete $rootScope.choosenChallenger
          delete $rootScope.gameProcess
          delete $rootScope.choosenCategory
          delete $rootScope.choosenGame
          $rootScope.gameInProgress = false
        , utils.finishTime
      .error ->
        window.utils.request = reqData
        localStorage.setItem('saveGame', JSON.stringify({url: reqData.url, data:reqData.data}))

        $rootScope.gameInProgress = false
        $rootScope.choosenOpponentType = $scope.opponentType
        $rootScope.offlineHandler()

    delete $rootScope.finishGameObj

    $rootScope.gameProcess = true

    _this = this

    TIME_FROM_ANSWER = 45

    $scope.STRIKES_COUNT = 3

    $scope.sortableCtrl =
      containment: 'body'

    $scope.animateSortedCtrl =
      sortedEnd: ->
        $scope.$apply ->
          goToFinishGameFn()

    gameData =
      my:
        correctAnswers: 0
        time: 0
        detailsQuestions: {}
      opponent:
        correctAnswers: 0
        time: 0

    $scope.progress =
      time:
        my: 100
        opponent: 100
      answers:
        my: 100
        opponent: 100


    $rootScope.gameData = $rootScope.gameData[0]

    sortArray = []

    for item, index in $rootScope.gameData.question.answers
      sortArray.push item

    sortArray.sort (a, b)-> a.order - b.order

    $rootScope.gameData.comp_answer.sort (a, b)->
      a.time_response - b.time_response

    for item, index in sortArray
      for item2, index2 in $rootScope.gameData.question.answers
        if item2.order == item.order then item2.order = index

    _this.pkQuestion = $rootScope.gameData.question.id

    gameData.my.detailsQuestions[_this.pkQuestion] = []

    for key of gameData
      if $scope.opponentType == 'challenge' && key == 'opponent'
        continue

      $scope.toNextStrike key


app.controller 'gameProcessPriorityCtrl', [
  '$scope'
  '$http'
  '$filter'
  '$timeout'
  '$location'
  '$baseUrl'
  '$rootScope'
  '$interval'
  ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $interval) ->
    new Controllers.GameProcessPriorityController($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $interval)
]