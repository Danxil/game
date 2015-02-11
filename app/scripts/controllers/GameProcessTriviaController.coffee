'use strict'

class Controllers.GameProcessTriviaController extends Controllers.BaseController
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

    $scope.finishGame = ->
      gameData.opponent = correctAnswers: 0, time: 0

      for item in $scope.gameData
        gameData.opponent.time += item.comp_answer.time_response

        if item.comp_answer.correct then gameData.opponent.correctAnswers++

      goToFinishGameFn()

    cancelTimeLeftInterval = (player)->
      $interval.cancel _this.timeLeftInterval[player]

      delete _this.timeLeftInterval[player]

      $scope.pause[player] = true

    $scope.checkAnswer = (data, player)->
      cancelTimeLeftInterval(player)

      result = checkAnswerFn data, player

      if result == undefined
        return

      if $scope.indexQuestion[player] < $scope.gameData.length - 1
        $timeout ->
          $scope.toNextQuestion player
        , utils.finishTime
      else if player == 'my'
        goToFinishGameFn()
      else
        $scope.correctAnswer[player] = undefined

    $scope.toNextQuestion = (player)->
      toNextQuestionFn player

    checkAnswerFn = (result, player)->
      if $scope.correctAnswer[player] != undefined || ($scope.timeOver && $scope.timeOver[player])
        return;

      callback = (result, answerIndex)->
        if result
          gameData[player].correctAnswers++

          $scope.progress.answers[player] = (1 - gameData[player].correctAnswers / $rootScope.gameData.length) * 100

          $scope.correctAnswer[player] = true
        else
          $scope.correctAnswer[player] = false

        if player == 'my'
          gameData.my.detailsQuestions[_this.pkQuestion][0].response_time = TIME_FROM_ANSWER - $scope.timeLeft[player]
          gameData.my.detailsQuestions[_this.pkQuestion][0].correct = $scope.correctAnswer[player]

        gameData[player].time += TIME_FROM_ANSWER - $scope.timeLeft[player]

        result

      if typeof result == 'number'
        for answer, i in $scope.question.answers
          if answer.id == result
            callback answer.correct

            break
      else if typeof result == 'boolean'
        callback result

    toNextQuestionFn = (player)->
      if !$scope.indexQuestion then $scope.indexQuestion = my: -1, opponent: -1

      $scope.indexQuestion[player]++

      if !$scope.correctAnswer then $scope.correctAnswer = {}
      if !$scope.timeLeft then $scope.timeLeft = {}
      if !$scope.timeOver then $scope.timeOver = {}
      if !_this.answersTimeStart then _this.answersTimeStart = {}
      if !_this.timeLeftInterval then _this.timeLeftInterval = {}
      if !$scope.pause then $scope.pause = my: false, opponent: false

      $scope.correctAnswer[player] = undefined

      if !_this.answersTimeStart[player] then _this.answersTimeStart[player] = new Date

      $scope.timeLeft[player] = TIME_FROM_ANSWER

      $scope.timeOver[player] = false

      $scope.pause[player] = false

      switch player
        when 'my'
          $scope.question = $scope.gameData[$scope.indexQuestion[player]].question

          _this.pkQuestion = $rootScope.gameData[$scope.indexQuestion[player]].question.id

          gameData.my.detailsQuestions[_this.pkQuestion] = [{}]
        when 'opponent'
          $scope.opponentAnswer = $rootScope.gameData[$scope.indexQuestion[player]].comp_answer

      if !_this.timeLeftInterval[player]
        _this.timeLeftInterval[player] = $interval ->
          $scope.timeLeft[player]--

          $scope.progress.time[player] = (1 - (gameData[player].time + TIME_FROM_ANSWER - $scope.timeLeft[player]) / (TIME_FROM_ANSWER * $scope.gameData.length)) * 100

          if $scope.timeLeft[player] <= 0
            $scope.checkAnswer(false, player)

            $scope.timeOver[player] = true

            return

          if player == 'opponent' && $scope.opponentType != 'challenge' && $scope.opponentAnswer && TIME_FROM_ANSWER - $scope.timeLeft[player] + 1 >= $scope.opponentAnswer.time_response
            $scope.checkAnswer($scope.opponentAnswer.correct, 'opponent')
        , 1000

    goToFinishGameFn = ->
      cancelTimeLeftInterval('my')
      cancelTimeLeftInterval('opponent')

      gameWon = gameData.my.correctAnswers > gameData.opponent.correctAnswers ||
                (gameData.my.correctAnswers == gameData.opponent.correctAnswers && gameData.my.time < gameData.opponent.time)

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

          $rootScope.finishGameObj.gameType = $rootScope.choosenGame.game_type

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


    _this = this

    TIME_FROM_ANSWER = 9

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

    delete $rootScope.finishGameObj

    $rootScope.gameProcess = true

    for key of gameData
      if $scope.opponentType == 'challenge' && key == 'opponent'
        continue

      $scope.toNextQuestion key

app.controller 'gameProcessTriviaCtrl', [
  '$scope'
  '$http'
  '$filter'
  '$timeout'
  '$location'
  '$baseUrl'
  '$rootScope'
  '$interval'
  ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $interval) ->
    new Controllers.GameProcessTriviaController($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $interval)
]