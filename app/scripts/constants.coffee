constants = angular.module 'constants', []

if bowser.windowsphone and bowser.version == "10.0"
  tStart = "MSPointerDown"
  tMove = "MSPointerMove"
  tEnd = "MSPointerUp"
else if bowser.windowsphone and bowser.version == "11.0"
  tStart = "pointerdown"
  tMove = "pointermove"
  tEnd = "pointerup"
else
  tStart = "touchstart"
  tMove = "touchmove"
  tEnd = "touchend"

window.touchEvents = {tStart: tStart, tMove: tMove, tEnd: tEnd}

class Constants

  constructor: () ->

    @socialTypes =
      FB: 'fb'
      TW: 'tw'
      LN: 'in'
      MAIL: 'ma'

    @FbTemplate = (link) -> "Sign up for The Great Mobile Challenge – #{link} – and see if your enterprise mobility knowledge can take you to the top of the leaderboard."
    @TwitterTemplate = (link) -> "Join me on The Great Mobile Challenge and test your enterprise #mobility knowledge – sign up here: #{link}"
    @LnTemplate = (link) -> "Sign up for The Great Mobile Challenge – #{link} – and see if your enterprise mobility knowledge can take you to the top of the leaderboard."
    @MailTemplate = (link) -> "Hi,\n\nI’ve taken on The Great Mobile Challenge – and I thought you’d like to join me.
                    Put your enterprise mobility knowledge to the test to earn badges, win points and climb
                    the leaderboard!\n\n Sign up here to start your challenge: #{ link }"

  getSharingTemplate: (social=@socialTypes.FB, link) ->
    message = ''
    switch social
      when @socialTypes.FB then message = @FbTemplate(link)
      when @socialTypes.TW then message = @TwitterTemplate(link)
      when @socialTypes.LN then message = @LnTemplate(link)
      else
        message = @MailTemplate(link)
    message

  prepareMessage: (social=@socialTypes.FB, text) ->
    switch social
      when @socialTypes.TW
        text = text.replace(/#/g, "%23")
      when @socialTypes.MAIL
        text = text.replace(/\n/g, "%0D%0A")
    text


constants.service "Constants", [Constants]
