'use strict'

class Controllers.RegistrationController extends Controllers.BaseController
  @$inject = [
    '$scope'
    '$http'
    '$filter'
    '$timeout'
    '$location'
    '$baseUrl'
    '$rootScope'
    '$stateParams'
    '$controller'
    '$avatars'
    'AuthService'
    '$orientation'
  ]

  constructor: ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $stateParams, $controller, $avatars, AuthService, $orientation) ->
    super($scope, $rootScope)
    $scope.FIRST_STEP_FIELDS =
    [
      'first_name'
      'last_name'
      'email'
      'username'
      'password'
      'company'
      'receive_notification'
      'invitation_code'
    ]

    $scope.registrationData =
      data: {invitation_code: $stateParams.code or ''}
      error: {}

    if (typeof SetElqContent == "function")
      SetElqContent()

    $scope.checkRegistrationFields = (field, callback) ->
      emailSet() if field == 'email' && typeof emailSet == "function"
      checkObj = {}
      if (field != '*')
        if field == "receive_notification"
          if !$scope.registrationData.error
            $scope.registrationData.error = {}
          if !$scope.registrationData.data['receive_notification']
            $scope.registrationData.error['receive_notification'] = true
            return false
          else
            delete $scope.registrationData.error
            return true
        if ($scope.registrationData.data[field] && $scope.registrationData.data[field].length)

          checkObj[field] = $scope.registrationData.data[field]

          $http.post('/api/register/', checkObj).error((data, code) =>
            if (data[field])
              if (!$scope.registrationData.error)
                $scope.registrationData.error = {}

              if $scope.registrationData.error[field] != data[field]
                  $scope.registrationData.error[field] = data[field]
            else
              if $scope.registrationData.error
                delete $scope.registrationData.error[field]

              for key, field of $scope.registrationData.error
                if $scope.FIRST_STEP_FIELDS.indexOf(key) != -1 && !formInvalid
                  formInvalid = true

              if Object.keys($scope.registrationData.data).length < $scope.FIRST_STEP_FIELDS.length
                formInvalid = true

              if (!formInvalid)
                delete $scope.registrationData.error
          )
        else
          if !$scope.registrationData.error
            $scope.registrationData.error = {}

          $scope.registrationData.error[field] = ''
      else
        checkObj = $scope.registrationData.data

        if not $scope.registrationData.data.receive_notification
          if !$scope.registrationData.error
            $scope.registrationData.error = {}
          $scope.registrationData.error['receive_notification'] = true
          return false

        delete $scope.registrationData.error = {}

        $http.post('/api/register/', checkObj).error((data, code) ->
          for key, field of data
            if $scope.FIRST_STEP_FIELDS.indexOf(key) != -1
              if !formInvalid then formInvalid = true

              if $scope.registrationData.data[key] && $scope.registrationData.data[key].length
                $scope.registrationData.error[key] = field
              else
                $scope.registrationData.error[key] = ''

          if !formInvalid
            callback()
        )

    $scope.chooseGender = (type) ->
      if type == $scope.selectedGender
        return

      $scope.selectedGender = type

    $scope.registrationSubmit = ->
      !$scope.checkRegistrationFields '*', ()->
        $scope.registrationData.data['lns'] = angular.element("#lns").val()
        $scope.registrationData.data['elqCustomerGUID'] = angular.element("#elqCustomerGUID").val()
        $scope.registrationData.data.avatar = _this.choosenAvatarsObj[$scope.selectedGender].choose
        $scope.registrationData.data.avatar_bg = _this.choosenAvatarsObj[$scope.selectedGender].bg
        $rootScope.registrationData = $scope.registrationData.data || {}
        $location.url($location.path()) if $rootScope.registrationData.invitation_code

        $http.post('/api/register/', $rootScope.registrationData).success (data, code) ->
          signInData =
            username: $rootScope.registrationData.email
            password: $rootScope.registrationData.password
          try
            trackGoogle()
            trackAtlas()
          catch e
            console.log("Scripts error", e)

          AuthService.login(signInData).then((userInfo) ->
            $rootScope.userData = userInfo

            if $orientation.getStateTarget() == 'panel'
              $scope.goToChooseCategory()
            else
              $scope.goToHowToPlay($orientation.getStateTarget(), true)
          , (error) ->
              $scope.goToSignIn()
          )

    $avatars.getAllAvatars().then (data)->
      $scope.avatarsObj =
        '0': []
        '1': []

      i = 0

      while i < data.length
        $scope.avatarsObj[data[i].type].push data[i]

        i++

      $scope.chooseGender 0

      $scope.avatarSwiperCtrl = {}

      for key of $scope.avatarsObj
        $scope.avatarSwiperCtrl[key] = {}

        $scope.avatarSwiperCtrl[key].chooseAvatar = (avatar, index) ->
          _this.choosenAvatarsObj[avatar.type].choose = avatar.id
          _this.choosenAvatarsObj[avatar.type].bg = avatar.bg
          _this.choosenAvatarsObj[avatar.type].index = index

        $scope.avatarSwiperCtrl[key].createdSuccess = ->
          if !_this.choosenAvatarsObj then _this.choosenAvatarsObj = {}
          if !_this.choosenAvatarsObj[$scope.selectedGender] then _this.choosenAvatarsObj[$scope.selectedGender] = {}

          @slideTo(_this.choosenAvatarsObj[$scope.selectedGender].index  || 0)

    _this = @

app.controller 'registrationCtrl', [
  '$scope'
  '$http'
  '$filter'
  '$timeout'
  '$location'
  '$baseUrl'
  '$rootScope'
  '$stateParams'
  '$controller'
  '$avatars'
  'AuthService'
  '$orientation'
  ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $stateParams, $controller, $avatars, AuthService, $orientation) ->
    new Controllers.RegistrationController($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $stateParams, $controller, $avatars, AuthService, $orientation)
]