services = angular.module('services', [])

services.service "$baseUrl", -> location.origin

services.factory '$randomValue', -> (min,max) ->
  Math.floor Math.random() * (max - min + 1) + min

services.factory "$profile", [
  "$http"
  "$q"
  ($http, $q, $window, $baseUrl) ->
    getProfile: (userId)->
      $http.get '/api/profile/', params:
        id: userId
]


class AuthService
  constructor:($http, $q, $window, ipCookie, $cookies, $baseUrl, $rootScope) ->
    @$http = $http
    @$q = $q
    @$window = $window
    @ipCookie = ipCookie
    @$cookies = $cookies
    @$baseUrl = $baseUrl
    @$rootScope = $rootScope
    @userInfo = null

  login: (loginData) ->
    deferred = @$q.defer()

    @$http.post("/api/login/", loginData).then((result) =>
      @userInfo = result.data
      @$rootScope.pedingChallengesCount = parseInt(@userInfo.pending_count)
      if @ipCookie('first') is undefined
        @ipCookie('first', '1', expires: 30)

      @$http.get('/api/share-link/').then (result)=>
        @userInfo.refLink = 'http://' + document.location.host + '/#/r/' + result.data.hash
        window.utils.share_code = result.data.hash

        deferred.resolve(@userInfo)
      , (error) ->
          deferred.reject(error)
    , (error) ->
        deferred.reject(error)
    )

    deferred.promise

  getUser: ->
    if @userInfo then @userInfo else @login()

  updateUser: ->
    @login()

services.factory 'AuthService',[
  "$http",
  "$q",
  "$window",
  'ipCookie',
  '$cookies',
  '$baseUrl',
  '$rootScope',
  ($http, $q, $window, ipCookie, $cookies, $baseUrl, $rootScope) ->
    new AuthService($http, $q, $window, ipCookie, $cookies, $baseUrl, $rootScope)
]


services.factory "ProfileService", [
  "$http"
  "$q"
  '$route'
  ($http, $q, $route) ->
    factory =
      get_profile: (id = $route.current.params.id) ->
        deferred = $q.defer()
        $http.get("/api/profile/?id=#{ id }").then((result) ->
          deferred.resolve(result.data)
        , (error) ->
            deferred.reject(error)
        )

        deferred.promise

    factory
]


services.factory "$avatars", [
  "$http"
  "$q"
  '$route'
  ($http, $q, $route) ->
    factory =
      getAllAvatars: ->
        deferred = $q.defer()

        $http.get('/api/avatar/').success (result, code) ->
          deferred.resolve result

        deferred.promise

    factory
]

services.factory "LeaderBoardService", [
  "$http"
  "$q"
  ($http, $q) ->
    factory =

      makeRequest: (params = {}) ->
        deferred = $q.defer()
        $http.get('/api/leaderboard/', params: params
        ).then((result) ->
          deferred.resolve(result.data)
        , (error) ->
            deferred.reject(error)
        )

        deferred.promise

      getFriends: (page = 1) ->
        params =
          friends: '',
          page: page
        this.makeRequest(params)

      getFrequentPlayers: (page = 1) ->
        params =
          frequent: '',
          page: page
        this.makeRequest(params)

      getTop10: () ->
        this.makeRequest()
    factory
]

services.factory "$challengesService", [
  "$http"
  "$q"
  ($http, $q) ->
    makeRequest: (params = {}) ->
      deferred = $q.defer()
      $http.get('/api/challenge/', params: params
      ).then((result) ->
        deferred.resolve(result)
      , (error) ->
        deferred.reject(error)
      )

      deferred.promise

    getPendingChallenges: (page = 1) ->
      params = page: page
      this.makeRequest(params)

    getSentChallenges: (page = 1) ->
      params =
          challenger: '',
          page: page
      this.makeRequest(params)
]

services.factory "$howToService", [
  "$http"
  "$q"
  ($http, $q) ->
    _data = undefined

    _reqData = (params)->
      $http.get '/api/how-to/', params: params

    getMainData: (params = {}) ->

      deferred = $q.defer()

      if _data then deferred.resolve _data
      else
        _reqData params
        .success (data) ->
          deferred.resolve _data = data

      deferred.promise

    getLoadingData: (params = {}) ->

      params.visual = ''

      deferred = $q.defer()

      _reqData params
      .then ((data) -> deferred.resolve data), (data) -> deferred.reject data

      deferred.promise


    getTypeData: (type) ->
      result = []

      for item in _data
        if item.type == parseInt type then result.push item

      result
]

services.factory "$gameService", [
  "$http"
  "$q"
  ($http, $q) ->
    getQuestions: (pk, params = {}) ->
      deferred = $q.defer()

      $http.get '/api/game/' + pk + '/questions/', params: params
      .then (result)->
        deferred.resolve result
      , (result)-> deferred.reject result

      deferred.promise

    getGameByName: (name) ->
      deferred = $q.defer()

      $http.get '/api/game/' + name
      .then (result) ->
        deferred.resolve result
      , (error)->
        deferred.reject error

      deferred.promise

    getChallengeById: (id) ->
      deferred = $q.defer()

      $http.get '/api/challenge/' + id
      .then (result) ->
        deferred.resolve result
      , (error)->
        deferred.reject error

      deferred.promise

    checkUserAllow: (userPk, gamePk)->
      deferred = $q.defer()

      $http.post '/api/challenge/check/',
        challenged: userPk
        game: gamePk
      .then (result)->
        deferred.resolve result
      , (error)->
        deferred.reject error

      deferred.promise
]


class NotificationService
  constructor:($http, $q) ->
    @$http = $http
    @$q = $q

  getNotifications: (params = {}) ->
      deferred = @$q.defer()
      @$http.get('/api/notifications/', params: params
      ).then((result) ->
        deferred.resolve(result)
      , (error) ->
        deferred.reject(error)
      )

      deferred.promise

    getBadgesNotifications: () ->
      params = badge_notification: ''
      this.getNotifications(params)

    getLastResult: () ->
      params = last_result: ''
      this.getNotifications(params)

services.factory "$notificationService", [
  "$http"
  "$q"
  ($http, $q) ->
    new NotificationService($http, $q)
]


services.factory "socket", [
  "$rootScope"
  "ipCookie"
  "$q"
  "$location"
  "AuthService"
  "$cookies"
  "$timeout"
  ($rootScope, ipCookie, $q, $location, AuthService, $cookies, $timeout) ->
    fn = ->
      if !$rootScope.socket and ipCookie('token')?
        websocket_server = "#{ $location.$$protocol }://#{ $location.$$host }:#{nodePort}"
        socket = io.connect(websocket_server, {'query': "token=#{ ipCookie('token') }" })

        socket.on 'connect', () ->
          console.log('Client has connected to the server!')

        socket.on 'message', (data) ->
          console.log('Received a message from the server!', data)

        socket.on 'pending', (data) ->
          console.log('Received a pending message from the server!', data)
          $rootScope.pedingChallengesCount = parseInt(data)
          $rootScope.chooseList($rootScope.selectedList) if $rootScope.selectedList?
          $rootScope.$apply()

        socket.on 'leaderboard', (data) ->
          console.log('Received a leaderboard message from the server!', data)
#         $rootScope.leaderBoardChanged = parseInt(data)

          if !$rootScope.leaderboardUpdate then $rootScope.leaderboardUpdate = 1

          $rootScope.leaderboardUpdate++
          $rootScope.$apply()

        socket.on 'profile', (data) ->
          console.log('Received a profile message from the server!', data)
          $rootScope.profileCount = parseInt(data)
          $rootScope.$apply()

        socket.on 'userdata', (data) ->
          console.log('Received a request update from the server!', data)
          userInfo = AuthService.updateUser();
          $q.when(userInfo).then(
            (userInfo)->
              $rootScope.userData = userInfo

              $rootScope.chooseList($rootScope.selectedList) if $rootScope.selectedList?
            (error) ->
              $q.reject({ authenticated: false })
          )

        socket.on 'disconnect', () ->
          $rootScope.socket = null
          console.log('The client has disconnected!')

        $rootScope.socket = socket
        (error) ->
          console.log("Websocket error", error)

    $rootScope.$watch(()->
      return $cookies.token
    , (value) ->
        if $cookies.token != undefined
          if (typeof(WebSocket) != "function")
            $timeout fn, 10000
          else
            fn()
    )

    "someValue"
]

services.factory "$orientation", [
  '$rootScope'
  '$window'
  '$state'
  '$timeout'
  'stateLocationService'
  ($rootScope, $window, $state, $timeout, stateLocationService) ->
    getStateTarget: ->
      return if $window.innerWidth >= 1024 then 'panel' else 'app'

    windowResize: ->
      $rootScope.appViewList = []
      if this.getStateTarget() == 'panel' && ($state.includes('root.app.note') || $state.includes('root.app.how-to-play') || $state.includes('root.app.invite-friends') || $state.includes('root.app.pending-challenges') || $state.includes('root.app.profile') || $state.includes('root.app.my-profile') || $state.includes('root.app.leaderboard'))
        panelStateName = 'root.panel.' + $state.current.name.split('.')[2]
        panelStateParams = $state.params
        $rootScope.appViewList.push(appView.state.name) for appView in stateLocationService.stateHistory when appView.state.name.split('.')[2] not in ['note', 'how-to-play', 'invite-friends', 'pending-challenges', 'profile', 'my-profile', 'leaderboard']
        $state.go($rootScope.appViewList[$rootScope.appViewList.length - 1], {}, {reload: true})
        $timeout ->
          $state.go(panelStateName, panelStateParams)
        , 10
      if this.getStateTarget() == 'app'
        $rootScope.appViewList.push(stateLocationService.stateHistory[stateLocationService.stateHistory.length - 1].state.name)
]

services.factory "Navigation", [
  '$rootScope'
  '$location'
  '$window'
  '$state'
  '$orientation'
  'stateLocationService'
  ($rootScope, $location, $window, $state, $orientation, stateLocationService) ->

    $rootScope.checkState = (state)->
      if $rootScope.stateStorage.app.state.name == state || $rootScope.stateStorage.panel.state.name == state then true else false

    $rootScope.backHistory = ->
      prevState = stateLocationService.statePop()
      $state.go(prevState.state, prevState.params)

    $rootScope.goToMain = ->
      $state.go('root.app.main')

    $rootScope.goToLogged = ->
      $state.go('root.app.logged')

    $rootScope.goToSignIn = ->
      $state.go('root.app.sign-in')

    $rootScope.goToRegistration = ->
      $state.go('root.app.registration')

    $rootScope.goToHowToPlay = (target, afterRegister)->
      if afterRegister
        $rootScope.showMenu = false
      else
        $rootScope.showMenu = true

      $state.go('root.' + (if target then target else $orientation.getStateTarget()) + '.how-to-play')

    $rootScope.goToChooseOpponent = ->
      $state.go('root.app.game.choose-opponent')

    $rootScope.goToChooseCategory = ->
      $state.go('root.app.game.choose-category')

    $rootScope.goToChooseGame = ->
      $state.go('root.app.game.choose-game')

    $rootScope.goToGameProcessTrivia = ->
      $state.go('root.app.game.game-process-trivia')

    $rootScope.goToGameProcessPriority = ->
      $state.go('root.app.game.game-process-priority')

    $rootScope.goToGameProcessWord = ->
      $state.go('root.app.game.game-process-word')

    $rootScope.goToGameLoading = (game)->
      if game
        $rootScope.choosenGame = game

      $state.go('root.app.game.game-loading')

    $rootScope.goToGameWon = ->
      $state.go('root.app.game.game-won')

    $rootScope.goToGameCongrats = ->
      $state.go('root.app.game.game-congrats')

    $rootScope.goToGameLose1 = ->
      $state.go('root.app.game.game-lose-1')

    $rootScope.goToGameLose2 = ->
      $state.go('root.app.game.game-lose-2')

    $rootScope.goToInviteFriends = ->
      $state.go('root.' + $orientation.getStateTarget() + '.invite-friends')

    $rootScope.goToLeaderboard = (target)->
      $state.go('root.' + (if target then target else $orientation.getStateTarget()) + '.leaderboard')

    $rootScope.goToMyProfile = (target)->
      $state.go('root.' + (if target then target else $orientation.getStateTarget()) + '.my-profile')

    $rootScope.goToChallengeSent = ()->
      $state.go('root.app.game.challenge-sent')

    $rootScope.goToInvalidOpponent = ->
      $state.go('root.app.game.invalid-opponent')

    $rootScope.goToOtherProfile = (profile)->
      $rootScope.otherProfile = profile

      $state.go('root.' + $orientation.getStateTarget() + '.other-profile')

    $rootScope.goToPath = (toPath = '/choose-category') ->
      $state.go(toPath)

    $rootScope.goToPendingChallenges = ->
      $state.go('root.' + $orientation.getStateTarget() + '.pending-challenges')

    $rootScope.goToNote = (note)->
      $rootScope.choosenNote = note

      $state.go('root.' + $orientation.getStateTarget() + '.note')

    $rootScope.goToState = (state) ->
      $state.go state.name, state.params
]

class StateLocationService
  preventCall:[]
  stateHistory: []
  currentAppState:
    name: null
  @$inject:['$state']
  constructor:(@state) ->

  stateChange: (fromState, fromParams, toState) ->
    if @preventCall.pop() || !fromState.name.length || (/^root.panel.*$/i.test fromState.name) || (fromState.name.split('.')[2] in ['note', 'how-to-play', 'invite-friends', 'pending-challenges', 'profile', 'my-profile', 'leaderboard'])
      return
    stateObject =
      state: fromState
      params: fromParams
    if toState.name.length && !/^root.panel.*$/i.test toState.name
      @currentAppState = toState
    @stateHistory.push(stateObject)

  statePop: ->
    @preventCall.push 'stateChange'
    prevState = @stateHistory.pop()
    if prevState.state.name == @currentAppState.name
      prevState = @stateHistory.pop()
    prevState

services.service 'stateLocationService', StateLocationService
