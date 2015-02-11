"use strict"
window.utils = {
  finishTime: 4500
}
window.Controllers = {}

(_.flip setTimeout) 1000, ->   ## let it load something before firing warnings
  silence = localStorage? and localStorage.donotbotherme?
  warn = "
  Please note that AT&T no longer supports Internet Explorer versions lower than
  version 10. We recommend upgrading to the latest Internet Explorer, Google
  Chrome, or Firefox. If you are using IE 10 or later, make sure you turn off
  \"Compatibility View.\"
  "
  oldies = [
    bowser.msie? and bowser.version <= 9,
    bowser.firefox? and bowser.version <= 31,
    bowser.chrome? and bowser.version <= 36
  ]
  alert warn if (_.any oldies) and (not silence)

window.app = angular.module("app",
  [
    'directives'
    'filters'
    'services'
    'constants'
    'ngRoute'
    'ngAnimate'
    'ipCookie'
    'ngCookies'
    'ngSanitize'
    'infinite-scroll'
    'ui.router'
    'ct.ui.router.extras'
    'ui.sortable'
    'danxil.word-find'
  ])

app.config [
  "$stateProvider", '$urlRouterProvider'
  ($stateProvider, $urlRouterProvider, AuthService) ->
    $urlRouterProvider.rule ($injector, $location) ->

      path = $location.path()
      if path isnt "/" and path.slice(-1) is "/"
        $location.replace().path( path.slice(0, -1) )
        return

    stateTransform = (targetObj, object, target)->
      for key, value of object
        if typeof value != 'object'
          targetObj[key] = value

          if typeof value == 'string'
            targetObj[key] = targetObj[key].replace '{target}', target
        else
          newObj = {}
          targetObj[key] = stateTransform(newObj, value, target)

          if key == '{target}'
            targetObj[target] = targetObj[key]
            delete targetObj[key]

      return targetObj

    stateTargets = ['app', 'panel']

    dynamicStates =
    [
      {
        name: 'root.{target}'
        #url: '/{target}'
        views:
          '{target}':
            template: '<div class="view-animate" ui-view></div>'
        abstract: true
        deepStateRedirect: true
        sticky: true
      }
      {
        name: 'root.{target}.main'
        #url: "/main"
        templateUrl: "/views/lander.html"
        controller: "mainCtrl"
        resolve:
          auth: ["$q", "$rootScope", ($q, $rootScope) ->
            $q.when($rootScope.userData).then(
              (userInfo)->
                $q.reject({ authenticated: true }) if userInfo
            )
          ]
      }
      {
        name: 'root.{target}.sign-in'
        #url: "/sign-in"
        templateUrl: "/views/sign-in.html"
        controller: "mainCtrl"
        resolve:
          auth: ["$q", "$rootScope", ($q, $rootScope) ->
            $q.when($rootScope.userData).then(
              (userInfo)->
                $q.reject({ authenticated: true }) if userInfo
            )
          ]
      }
      {
        name: 'root.{target}.logged'
        #url: "/logged"
        templateUrl: "/views/logged.html"
        controller: "mainCtrl"
        resolve:
          auth: ["$q", "$rootScope", "AuthService", ($q, $rootScope, AuthService) ->
            userInfo = AuthService.getUser();
            $q.when(userInfo).then(
              (userInfo)->
                $rootScope.userData = userInfo
              (error) ->
                $q.reject({ authenticated: false })
            )
          ]
        deepStateRedirect: true
        sticky: true
      }
      {
        name: 'root.{target}.registration'
        url: "/r/:code"
        templateUrl: "/views/registration.html"
        controller: "registrationCtrl"
        resolve:
          auth: ["$q", "$rootScope", ($q, $rootScope) ->
            $q.when($rootScope.userData).then(
              (userInfo)->
                $q.reject({ authenticated: true }) if userInfo
            )
          ]
      }
      {
        name: 'root.{target}.how-to-play'
        #url: "/how-to-play"
        templateUrl: "/views/how-to-play.html"
        controller: "howToPlayCtrl"
      }
      {
        name: 'root.{target}.game'
        #url: '/game'
        template: '<div ui-view class="view-animate"></div>'
      }
      {
        name: 'root.{target}.game.choose-category'
        #url: '/choose-category'
        templateUrl: "/views/choose-category.html"
        controller: "chooseCategoryCtrl"
        resolve:
          auth: ["$q", "$rootScope", "AuthService", ($q, $rootScope, AuthService) ->
            userInfo = AuthService.getUser();
            $q.when(userInfo).then(
              (userInfo)->
                $rootScope.userData = userInfo
              (error) ->
                $q.reject({ authenticated: false })
            )
          ],
          categories: ["$q", "$http", ($q, $http) ->
            deferred = $q.defer()
            $http.get('/api/category/').then (data) ->
              deferred.resolve(data.data)
            deferred.promise
          ]
      }
      {
        name: 'root.{target}.game.choose-game'
        #url: '/choose-game'
        templateUrl: "/views/choose-game.html"
        controller: "chooseGameCtrl"
        resolve:
          auth: ["$q", "$rootScope", "AuthService", ($q, $rootScope, AuthService) ->
            userInfo = AuthService.getUser();
            $q.when(userInfo).then(
              (userInfo)->
                $rootScope.userData = userInfo
              (error) ->
                $q.reject({ authenticated: false })
            )
          ]
          checkData: ['$q', '$rootScope', ($q, $rootScope)->
            if !$rootScope.choosenCategory then $q.reject({ checkData: false })
          ]
      }
      {
        name: 'root.{target}.game.game-loading'
        #url: '/game-loading'
        templateUrl: "/views/game-loading.html"
        controller: "gameLoadingCtrl"
        resolve:
          auth: ["$q", "$rootScope", "AuthService", ($q, $rootScope, AuthService) ->
            userInfo = AuthService.getUser();
            $q.when(userInfo).then(
              (userInfo)->
                $rootScope.userData = userInfo
              (error) ->
                $q.reject({ authenticated: false })
            )
          ]
          visualInstruction: ["$q", "$rootScope", "$howToService", "$http", ($q, $rootScope, $howToService, $http) ->
            data = $howToService.getLoadingData
              game_type: $rootScope.choosenGame.game_type

            $q.when(data).then (result)->
              $http.get(result.data.image).then ->
                result.data
            , (result)-> {}
          ]
          checkData: ['$q', '$rootScope', ($q, $rootScope)->
            if !$rootScope.choosenGame then $q.reject({ checkData: false })
          ]
          preloadImages: ["$q", "$rootScope", "$http", ($q, $rootScope, $http) ->
            $http.get($rootScope.choosenGame.icon).then ->
          ]
      }
      {
        name: 'root.{target}.game.game-loading-invite-game'
        url: '/game/:gamename'
        templateUrl: "/views/game-loading.html"
        controller: "gameLoadingInviteGameCtrl"
        resolve:
          auth: ["$q", "$rootScope", "AuthService", '$stateParams', ($q, $rootScope, AuthService, $stateParams) ->
            userInfo = AuthService.getUser();
            $q.when(userInfo).then(
              (userInfo)->
                $rootScope.userData = userInfo
              (error) ->
                $rootScope.redirectAfterLoginState =
                  name: 'root.app.game.game-loading-invite-game'
                  params:
                    gamename: $stateParams.gamename

                $q.reject({ authenticated: false })
            )
          ]
          visualInstruction: ["$q", "$rootScope", "$howToService", '$stateParams', '$http', ($q, $rootScope, $howToService, $stateParams, $http) ->
            data = $howToService.getLoadingData
              game_title: $stateParams.gamename
              visual: ''

            $q.when(data).then (result)->
              $http.get(result.data.image).then ->
                result.data
            , (result)-> {}
          ]
          game: ['$q', '$gameService', '$stateParams', '$http', ($q, $gameService, $stateParams, $http)->
            game = $gameService.getGameByName($stateParams.gamename)

            $q.when(game)
            .then (result)->
              result.data
            , (error)->
              $q.reject checkData: false
          ]
      }
      {
        name: 'root.{target}.game.game-loading-invite-challenge'
        url: '/challenge/:challengeid'
        templateUrl: "/views/game-loading.html"
        controller: "gameLoadingInviteChallengeCtrl"
        resolve:
          auth: ["$q", "$rootScope", "AuthService", '$stateParams', ($q, $rootScope, AuthService, $stateParams) ->
            userInfo = AuthService.getUser();
            $q.when(userInfo).then(
              (userInfo)->
                $rootScope.userData = userInfo
              (error) ->
                $rootScope.redirectAfterLoginState =
                  name: 'root.app.game.game-loading-invite-challenge'
                  params:
                    challengeid: $stateParams.challengeid

                $q.reject({ authenticated: false })
            )
          ]
          visualInstruction: ["$q", "$rootScope", "$howToService", '$stateParams', '$http', ($q, $rootScope, $howToService, $stateParams, $http) ->
            data = $howToService.getLoadingData
              challenge: $stateParams.challengeid
              visual: ''

            $q.when(data).then (result)->
              $http.get(result.data.image).then ->
                result.data
            , (result)-> {}
          ]
          challenge: ['$rootScope', '$q', '$gameService', '$stateParams', '$http', ($rootScope, $q, $gameService, $stateParams, $http)->
            game = $gameService.getChallengeById($stateParams.challengeid)

            $q.when(game)
            .then (result)->
              $http.get(result.data[0].game_icon).then ->
                result.data
            , (error)->
              $q.reject checkData: false
          ]
      }
      {
        name: 'root.{target}.game.game-process-trivia'
        #url: '/game-process-main'
        templateUrl: "/views/game-process-trivia.html"
        controller: "gameProcessTriviaCtrl"
        resolve:
          auth: ["$q", "$rootScope", "AuthService", ($q, $rootScope, AuthService) ->
            userInfo = AuthService.getUser();
            $q.when(userInfo).then(
              (userInfo)->
                $rootScope.userData = userInfo
              (error) ->
                $q.reject({ authenticated: false })
            )
          ]
          checkData: ['$q', '$rootScope', ($q, $rootScope)->
            if !$rootScope.gameData then $q.reject({ checkData: false })
          ]
      }
      {
        name: 'root.{target}.game.game-process-priority'
        #url: '/game-process-priority'
        templateUrl: "/views/game-process-priority.html"
        controller: "gameProcessPriorityCtrl"
        resolve:
          auth: ["$q", "$rootScope", "AuthService", ($q, $rootScope, AuthService) ->
            userInfo = AuthService.getUser();
            $q.when(userInfo).then(
              (userInfo)->
                $rootScope.userData = userInfo
              (error) ->
                $q.reject({ authenticated: false })
            )
          ]
          checkData: ['$q', '$rootScope', ($q, $rootScope)->
            if !$rootScope.gameData then $q.reject({ checkData: false })
          ]
      }
      {
        name: 'root.{target}.game.game-process-word'
        #url: '/game-process-word'
        templateUrl: "/views/game-process-word.html"
        controller: "gameProcessWordCtrl"
        resolve:
          auth: ["$q", "$rootScope", "AuthService", ($q, $rootScope, AuthService) ->
            userInfo = AuthService.getUser();
            $q.when(userInfo).then(
              (userInfo)->
                $rootScope.userData = userInfo
              (error) ->
                $q.reject({ authenticated: false })
            )
          ]
          checkData: ['$q', '$rootScope', ($q, $rootScope)->
            if !$rootScope.gameData then $q.reject({ checkData: false })
          ]
      }
      {
        name: 'root.{target}.game.game-won'
        #url: '/game-won'
        templateUrl: "/views/game-won.html"
        resolve:
          auth: ["$q", "$rootScope", "AuthService", ($q, $rootScope, AuthService) ->
            userInfo = AuthService.getUser();
            $q.when(userInfo).then(
              (userInfo)->
                $rootScope.userData = userInfo
              (error) ->
                $q.reject({ authenticated: false })
            )
          ]
          checkData: ['$q', '$rootScope', ($q, $rootScope)->
            if !$rootScope.finishGameObj then $q.reject({ checkData: false })
          ]
      }
      {
        name: 'root.{target}.game.game-congrats'
        templateUrl: "/views/game-congrats.html"
        resolve:
          auth: ["$q", "$rootScope", "AuthService", ($q, $rootScope, AuthService) ->
            userInfo = AuthService.getUser();
            $q.when(userInfo).then(
              (userInfo)->
                $rootScope.userData = userInfo
              (error) ->
                $q.reject({ authenticated: false })
            )
          ]
          checkData: ['$q', '$rootScope', ($q, $rootScope)->
            if !$rootScope.finishGameObj then $q.reject({ checkData: false })
          ]
      }
      {
        name: 'root.{target}.game.game-lose-1'
        #url: '/game-lose-1'
        templateUrl: "/views/game-lose-1.html"
        controller: "gameLose1Ctrl"
        resolve:
          auth: ["$q", "$rootScope", "AuthService", ($q, $rootScope, AuthService) ->
            userInfo = AuthService.getUser();
            $q.when(userInfo).then(
              (userInfo)->
                $rootScope.userData = userInfo
              (error) ->
                $q.reject({ authenticated: false })
            )
          ]
          checkData: ['$q', '$rootScope', ($q, $rootScope)->
            if !$rootScope.finishGameObj then $q.reject({ checkData: false })
          ]
      }
      {
        name: 'root.{target}.game.game-lose-2'
        #url: '/game-lose-2'
        templateUrl: "/views/game-lose-2.html"
        resolve:
          auth: ["$q", "$rootScope", "AuthService", ($q, $rootScope, AuthService) ->
            userInfo = AuthService.getUser();
            $q.when(userInfo).then(
              (userInfo)->
                $rootScope.userData = userInfo
              (error) ->
                $q.reject({ authenticated: false })
            )
          ]
          checkData: ['$q', '$rootScope', ($q, $rootScope)->
            if !$rootScope.finishGameObj then $q.reject({ checkData: false })
          ]
      }
      {
        name: 'root.{target}.game.choose-opponent'
        #url: '/choose-opponent'
        templateUrl: "/views/choose-opponent.html"
        controller: "chooseOpponentCtrl"
        resolve:
          auth: ["$q", "$rootScope", "AuthService", ($q, $rootScope, AuthService) ->
            userInfo = AuthService.getUser();
            $q.when(userInfo).then(
              (userInfo)->
                $rootScope.userData = userInfo
              (error) ->
                $q.reject({ authenticated: false })
            )
          ]
          checkData: ['$q', '$rootScope', ($q, $rootScope)->
            if !$rootScope.choosenGame then $q.reject({ checkData: false })
          ]
      }
      {
        name: 'root.{target}.game.challenge-sent'
        #url: '/challenge-sent'
        templateUrl: "/views/challenge-sent.html"
        resolve:
          auth: ["$q", "$rootScope", "AuthService", ($q, $rootScope, AuthService) ->
            userInfo = AuthService.getUser();
            $q.when(userInfo).then(
              (userInfo)->
                $rootScope.userData = userInfo
              (error) ->
                $q.reject({ authenticated: false })
            )
          ]
          checkData: ['$q', '$rootScope', ($q, $rootScope)->
            if !$rootScope.finishGameObj then $q.reject({ checkData: false })
          ]
      }
      {
        name: 'root.{target}.game.invalid-opponent'
        #url: '/invalid-opponent'
        templateUrl: "/views/invalid-opponent.html"
        resolve:
          auth: ["$q", "$rootScope", "AuthService", ($q, $rootScope, AuthService) ->
            userInfo = AuthService.getUser();
            $q.when(userInfo).then(
              (userInfo)->
                $rootScope.userData = userInfo
              (error) ->
                $q.reject({ authenticated: false })
            )
          ]
      }
      {
        name: 'root.{target}.leaderboard'
        #url: "/leaderboard"
        templateUrl: "/views/leaderboard.html"
        controller: "leaderboardCtrl"
        resolve:
          auth: ["$q", "$rootScope", "AuthService", ($q, $rootScope, AuthService) ->
            userInfo = AuthService.getUser();
            $q.when(userInfo).then(
              (userInfo)->
                $rootScope.userData = userInfo
              (error) ->
                $q.reject({ authenticated: false })
            )
          ]
      }
      {
        name: 'root.{target}.invite-friends'
        #url: "/invite-friends"
        templateUrl: "/views/invite-friends.html"
        controller: "inviteFriendsCtrl"
        resolve:
          auth: ["$q", "$rootScope", "AuthService", ($q, $rootScope, AuthService) ->
            userInfo = AuthService.getUser();
            $q.when(userInfo).then(
              (userInfo)->
                $rootScope.userData = userInfo
              (error) ->
                $q.reject({ authenticated: false })
            )
          ]
      }
      {
        name: 'root.{target}.my-profile'
        #url: '/my-profile'
        templateUrl: "/views/my-profile.html"
        controller: "myProfileCtrl"
        resolve:
          auth: ["$q", "$rootScope", "AuthService", ($q, $rootScope, AuthService) ->
            userInfo = AuthService.getUser();
            $q.when(userInfo).then(
              (userInfo)->
                $rootScope.userData = userInfo
              (error) ->
                $q.reject({ authenticated: false })
            )
          ]
      }
      {
        name: 'root.{target}.other-profile'
        #url: "/other-profile/:userId"
        templateUrl: "/views/other-profile.html"
        controller: "otherProfileCtrl"
        resolve:
          auth: ["$q", "$rootScope", "AuthService", ($q, $rootScope, AuthService) ->
            userInfo = AuthService.getUser();
            $q.when(userInfo).then(
              (userInfo)->
                $rootScope.userData = userInfo
              (error) ->
                $q.reject({ authenticated: false })
            )
          ]
          data: ['$rootScope', '$q', '$stateParams', '$profile', ($rootScope, $q, $stateParams, $profile) ->
            if $rootScope.otherProfile then return $rootScope.otherProfile

            deferred = $q.defer()

            $profile.getProfile($stateParams.userId).success (data)->
              deferred.resolve data

            deferred.promise
          ]
      }
      {
        name: 'root.{target}.pending-challenges'
        #url: "/pending-challenges"
        templateUrl: "/views/pending-challenges.html"
        controller: "pendingChallengesCtrl"
        resolve:
          auth: ["$q", "$rootScope", "AuthService", ($q, $rootScope, AuthService) ->
            userInfo = AuthService.getUser();
            $q.when(userInfo).then(
              (userInfo)->
                $rootScope.userData = userInfo
              (error) ->
                $q.reject({ authenticated: false })
            )
          ]
      }
      {
        name: 'root.{target}.note'
        #url: "/note/:url"
        templateUrl: "/views/note.html"
        controller: "noteCtrl",
      }
    ]

    $stateProvider.state 'root',
      views:
        left:
          template: '<div class="view-animate" ui-view="app"></div>'
        right:
          template: '<div class="view-animate" ui-view="panel"></div>'

    angular.forEach stateTargets, (target)->
      angular.forEach dynamicStates, (state)->
        #$stateProvider.state stateTransform {}, state, target

        newObj = {}

        for key, value of state
          if typeof value == 'string'
            newObj[key] = value.replace '{target}', target
          else
            if key == 'views'
              newObj.views = {}
              newObj.views[target] = value['{target}']
            else
              newObj[key] = value

        $stateProvider.state newObj
]

app.config [
  "$locationProvider"
  "$httpProvider"
  ($locationProvider, $httpProvider) ->
    $httpProvider.interceptors.push('httpRequestInterceptor')
#    $locationProvider.html5Mode true
]

app.run(["$rootScope", "$q", "$location", '$baseUrl', 'Navigation', '$window', '$orientation', '$state', 'stateLocationService'
  ($rootScope, $q, $location, $baseUrl, Navigation, $window, $orientation, $state, stateLocationService) ->
    $rootScope.$location = $location
    $rootScope.$baseUrl = $baseUrl
    $rootScope.$stateTarget = $orientation.getStateTarget
    $rootScope.$state = $state

    $rootScope.$on("$stateChangeError", (event, toState, toParams, fromState, fromParams, error) ->
      $rootScope.goToSignIn() if error.authenticated == false
      $rootScope.goToLogged() if error.authenticated == true || error.checkData == false
    )

    $rootScope.$on("$stateChangeSuccess", (event, toState, toParams, fromState, fromParams) ->
      _.doLater -> window.scrollTo 0, 1
      stateLocationService.stateChange(fromState, fromParams, toState)
      if !$rootScope.stateStorage then $rootScope.stateStorage = {}

      $rootScope.stateStorage[toState.name.split('.')[1]] =
        state: toState
        params: toParams
    )
])

app.factory 'httpRequestInterceptor', [
  'ipCookie'
  '$q'
  '$rootScope'
  ($ipCookie, $q, $rootScope) ->
    request: (config) ->
      config.headers['GMCAUTH'] = 'Token ' + $ipCookie 'token' if $ipCookie 'token'
      config
    requestError: (rejection) ->
      Offline.check()
      $q.reject(rejection)
    responseError: (rejection) ->
      Offline.check()
      $q.reject(rejection)

]
