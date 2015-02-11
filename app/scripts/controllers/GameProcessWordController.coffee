'use strict'

class Controllers.GameProcessWordController extends Controllers.BaseController
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

  constructor:($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $interval) ->

    $rootScope.gameInProgress = true

    goToFinishGameFn = ->
      cancelTimeLeftInterval('my')
      cancelTimeLeftInterval('opponent')

      lostAnswers = []

      for value, index in _this.answers.my
        lostAnswers[index] = []

        for value2, index2 in value.text
          lostAnswers[index][index2] = {}

          lostAnswers[index][index2].itemIndex = value2.item_index
          lostAnswers[index][index2].rowIndex = value2.row_index
          lostAnswers[index][index2].value = value2.letter

        addSelectedElems lostAnswers[index], $scope.correctIndexes

      $scope.finishGame()

    cancelTimeLeftInterval = (player)->
      $interval.cancel _this.timeLeftInterval[player]

    addSelectedElems = (data, result)->
      newData = []
      oldResult = []

      for value, index in result
        if !oldResult[value.rowIndex] then result[value.rowIndex] = {}
        if !oldResult[value.rowIndex][value.itemIndex] then oldResult[value.rowIndex][value.itemIndex]  = {}

      for value, index in data
        if !result[value.rowIndex] then result[value.rowIndex] = {}
        if !result[value.rowIndex][value.itemIndex] then result[value.rowIndex][value.itemIndex]  = {}

        if !newData[value.rowIndex] then newData[value.rowIndex] = {}
        if !newData[value.rowIndex][value.itemIndex] then newData[value.rowIndex][value.itemIndex]  = {}

      for rowIndex, row of newData
        for itemIndex, item of row
          itemIndex = parseInt itemIndex
          rowIndex = parseInt rowIndex

          if !result[rowIndex][itemIndex].position then result[rowIndex][itemIndex].position = {}

          ifItemVertical = (newData[rowIndex - 1] && newData[rowIndex - 1][itemIndex]) || (newData[rowIndex + 1] && newData[rowIndex + 1][itemIndex])
          ifItemHorisontal = newData[rowIndex] && (newData[rowIndex][itemIndex - 1] || newData[rowIndex][itemIndex + 1])
          ifItemDiagonal = (newData[rowIndex + 1] && (newData[rowIndex + 1][itemIndex + 1] || newData[rowIndex + 1][itemIndex - 1])) ||
                            (newData[rowIndex - 1] && (newData[rowIndex - 1][itemIndex + 1] || newData[rowIndex - 1][itemIndex - 1]))

          if ifItemVertical
            result[rowIndex][itemIndex].type = 'vertical'

          if ifItemHorisontal
            result[rowIndex][itemIndex].type = 'horisontal'

          if ifItemDiagonal
            result[rowIndex][itemIndex].type = 'diagonal'


          ifItemRightDiagonal = newData[rowIndex - 1] && newData[rowIndex - 1][itemIndex + 1] || newData[rowIndex + 1] && newData[rowIndex + 1][itemIndex - 1]
          ifItemLeftDiagonal = newData[rowIndex - 1] && newData[rowIndex - 1][itemIndex - 1] || newData[rowIndex + 1] && newData[rowIndex + 1][itemIndex + 1]

          if ifItemRightDiagonal
            result[rowIndex][itemIndex].position.right = true

          if ifItemLeftDiagonal
            result[rowIndex][itemIndex].position.left = true

          ifItemFirstVertical = ifItemVertical && (!newData[rowIndex - 1] || !newData[rowIndex - 1][itemIndex]) && (!oldResult[rowIndex] || !oldResult[rowIndex][itemIndex])
          ifItemFirstHorisontal = ifItemHorisontal && (!newData[rowIndex] || !newData[rowIndex][itemIndex - 1]) && (!oldResult[rowIndex] || !oldResult[rowIndex][itemIndex])
          ifItemFirstDiagonal = (ifItemRightDiagonal && (!newData[rowIndex - 1] || !newData[rowIndex - 1][itemIndex + 1]) && (!oldResult[rowIndex] || !oldResult[rowIndex][itemIndex])) ||
            (ifItemLeftDiagonal && (!newData[rowIndex - 1] || !newData[rowIndex - 1][itemIndex - 1]) && (!oldResult[rowIndex] || !oldResult[rowIndex][itemIndex]))

          if ifItemFirstVertical || ifItemFirstHorisontal || ifItemFirstDiagonal
            result[rowIndex][itemIndex].position.first = true
          else
            result[rowIndex][itemIndex].position.first = false

          ifItemLastVertical = ifItemVertical && (!newData[rowIndex + 1] || !newData[rowIndex + 1][itemIndex]) && (!oldResult[rowIndex] || !oldResult[rowIndex][itemIndex])
          ifItemLastHorisontal = ifItemHorisontal && (!newData[rowIndex] || !newData[rowIndex][itemIndex + 1])  && (!oldResult[rowIndex] || !oldResult[rowIndex][itemIndex])
          ifItemLastDiagonal = (ifItemRightDiagonal && (!newData[rowIndex + 1] || !newData[rowIndex + 1][itemIndex - 1]) && (!oldResult[rowIndex] || !oldResult[rowIndex][itemIndex])) ||
                                (ifItemLeftDiagonal && (!newData[rowIndex + 1] || !newData[rowIndex + 1][itemIndex + 1]) && (!oldResult[rowIndex] || !oldResult[rowIndex][itemIndex]))

          if ifItemLastVertical || ifItemLastHorisontal || ifItemLastDiagonal
            result[rowIndex][itemIndex].position.last = true
          else
            result[rowIndex][itemIndex].position.last = false

    $scope.checkAnswer = (data, player)->
      if player == 'my' then $scope.wfDisable = true

      result = checkAnswerFn data, player

      if player == 'my'
        switch result
          when true
            addSelectedElems data, $scope.correctIndexes
          when false
            addSelectedElems data, $scope.errorIndexes

            $timeout ->
              $scope.errorIndexes = {}
            , 1000

    $scope.toNextStrike = (player)->
      if player == 'my' then  $scope.wfDisable = false

      toNextStrikeFn player

    checkAnswerFn = (result, player)->
      if $scope.correctAnswer[player] != undefined || ($scope.timeOver && $scope.timeOver[player])
        return;

      callback = (result, answerIndex)->
        if result
          gameData[player].correctAnswers++

          $scope.progress.answers[player] = (1 - gameData[player].correctAnswers / $rootScope.gameData.question.answers.length) * 100

          $scope.correctAnswer[player] = true

          _this.answers[player].splice(answerIndex || 0, 1)
        else
          $scope.correctAnswer[player] = false

        if player == 'my'
          gameData.my.detailsQuestions[_this.pkQuestion][$scope.numberStrike[player]].response_time = TIME_FROM_ANSWER - $scope.timeLeft[player]
          gameData.my.detailsQuestions[_this.pkQuestion][$scope.numberStrike[player]].correct = $scope.correctAnswer[player]
          gameData.my.detailsQuestions[_this.pkQuestion][$scope.numberStrike[player]].answer = ''

        switch player
          when 'my'
            if _this.answers[player].length
              $timeout ->
                $scope.toNextStrike(player)
              , 500
            else
              goToFinishGameFn()
          when 'opponent'
            if _this.answers[player].length
              $timeout ->
                $scope.toNextStrike player
              , 500

        result

      check = (result, answers)->
        for checkValue, index in answers
          checkValue = checkValue.text

          correctItemCount = 0

          for resultValue, resultIndex in result
            if checkValue[resultIndex] && resultValue.value == checkValue[resultIndex].letter
              correctItemCount++

          if correctItemCount == checkValue.length && correctItemCount == result.length
            return index

        undefined

      switch typeof result
        when 'object'
          correctAnswerIndex = check result, _this.answers[player]

          if correctAnswerIndex != undefined
            callback true, correctAnswerIndex
          else
            correctAnswerIndex = check result.reverse(), _this.answers[player]

            if correctAnswerIndex != undefined
              callback true, correctAnswerIndex
            else
              callback false

        when 'boolean'
          callback result

    toNextStrikeFn = (player)->
      if !$scope.numberStrike then $scope.numberStrike = my: -1, opponent: -1

      $scope.numberStrike[player]++

      if $scope.timeOver && $scope.timeOver[player]
        return

      if !$scope.correctAnswer then $scope.correctAnswer = {}
      if !$scope.timeLeft then $scope.timeLeft = {}
      if !$scope.timeLeft[player] then $scope.timeLeft[player] = TIME_FROM_ANSWER
      if !$scope.timeOver then $scope.timeOver = {}
      if !_this.timeLeftInterval then _this.timeLeftInterval = {}
      if !_this.answers then _this.answers = {}
      if !$scope.correctIndexes then $scope.correctIndexes = {}
      if !$scope.errorIndexes then $scope.errorIndexes = {}

      if !_this.answers[player]
        _this.answers[player] = []

        for value, index in $rootScope.gameData.question.answers
          _this.answers[player][index] = $rootScope.gameData.question.answers[index]

      $scope.correctAnswer[player] = undefined

      $scope.timeOver[player] = false

      switch player
        when 'my'
          if !gameData.my.detailsQuestions[_this.pkQuestion][$scope.numberStrike[player]]
            gameData.my.detailsQuestions[_this.pkQuestion][$scope.numberStrike[player]] = {}

        when 'opponent'
          $scope.opponentAnswer = $rootScope.gameData.comp_answer[$scope.numberStrike[player]]

      if !_this.timeLeftInterval[player]
        _this.timeLeftInterval[player] = $interval ->

          $scope.timeLeft[player]--

          $scope.progress.time[player] = (1 - (TIME_FROM_ANSWER - $scope.timeLeft[player]) / TIME_FROM_ANSWER) * 100

          gameData[player].time = TIME_FROM_ANSWER - $scope.timeLeft[player]

          if $scope.timeLeft[player] <= 0 || !_this.answers[player].length
            if $scope.progress.time[player] < 1

              $scope.timeOver[player] = true

              if player == 'my' then goToFinishGameFn()

              return

          if player == 'opponent' && $scope.opponentType != 'challenge' && $scope.opponentAnswer && TIME_FROM_ANSWER - $scope.timeLeft[player] >= $scope.opponentAnswer.time_response
            $scope.checkAnswer($scope.opponentAnswer.correct, 'opponent')
        , 1000

    $scope.finishGame = ->
      gameWon = (gameData.my.correctAnswers > gameData.opponent.correctAnswers) ||
        (gameData.my.correctAnswers > 0 && gameData.my.correctAnswers == gameData.opponent.correctAnswers && gameData.my.time < gameData.opponent.time)

      if $scope.opponentType == 'computer'
        reqData =
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

      else if $scope.opponentType == 'challenge'
        reqData =
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

      else if $scope.opponentType == 'opponent'
        reqData =
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
          $rootScope.finishGameObj.gameType = $rootScope.choosenGame.game_type
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

    TIME_FROM_ANSWER = 60

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

    for answer in $rootScope.gameData.question.answers
      if answer.text[0].row_index != answer.text[1].row_index
        answer.text.sort (a, b) ->
          a.row_index - b.row_index
      else
        answer.text.sort (a, b) ->
          a.item_index - b.item_index

    $rootScope.gameData.comp_answer.sort (a, b)->
      a.time_response - b.time_response

    _this.pkQuestion = $rootScope.gameData.question.id

    gameData.my.detailsQuestions[_this.pkQuestion] = []

    $scope.wordFindActive = true

    $scope.wfCtrl =
      finishSelection: (values)->
        $scope.checkAnswer values, 'my'

    for key of gameData
      if $scope.opponentType == 'challenge' && key == 'opponent'
        continue

      $scope.toNextStrike key

app.controller 'gameProcessWordCtrl', [
  '$scope'
  '$http'
  '$filter'
  '$timeout'
  '$location'
  '$baseUrl'
  '$rootScope'
  '$interval'
  ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $interval) ->
    new Controllers.GameProcessWordController($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $interval)
]