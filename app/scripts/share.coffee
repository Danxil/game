get_share_email_text = ->
  if window.utils.share_code?
    link = " http://#{document.location.host}/#/r/#{window.utils.share_code}/"
  else
    link = " http://#{document.location.host}/"
  text = encodeURI """
  Hi

  I've taken on The Great Mobile Challenge - and I thought you'd like to join me. Put your enterprise mobility knowledge to the test to earn badges, win points and climb the leader board!

  Sign up here to start your challenge:
  """
  text + encodeURIComponent link

twitter_templates =
  r: (Handlebars.compile "Join me on The Great Mobile Challenge and test your enterprise #mobility knowledge: {{link}}"),
  i: (Handlebars.compile "Join me on The Great Mobile Challenge and test your enterprise #mobility knowledge – sign up here: {{link}}"),
  w: (Handlebars.compile "Bet you can't beat me in The Great Mobile Challenge. {{link}}"),
  b: (Handlebars.compile "Bagged it! Just earned a badge on The Great Mobile Challenge: {{link}} #mobility")

open_share_dialog = (source, network) ->
  w_open = window.open
  link_to_share = "http://#{document.location.host}/share/#{source}/"
  if window.utils.share_code? then link_to_share += "?ref=#{window.utils.share_code}"
  switch network
    when 'fb'
      lnk = "https://www.facebook.com/sharer/sharer.php?u=#{link_to_share}"
    when 'in'
      lnk = "https://www.linkedin.com/shareArticle?mini=true&url=#{link_to_share}"
    when 'tw'
      tmplt = twitter_templates[source]
      if tmplt?
        context = {link: link_to_share}
        lnk = "https://twitter.com/intent/tweet?text=#{encodeURIComponent(tmplt context)}"
      else
        lnk = "https://twitter.com/intent/tweet?text=#{encodeURIComponent link_to_share}"
    when 'ma'
      subject = encodeURIComponent "Join me on The Great Mobile Challenge"
      body = get_share_email_text()
      lnk = "mailto:?subject=#{ subject }&body=#{ body }"
      w_open = (link, ...) -> window.location = link
  w_open lnk, 'Share', 'height=320, width=640, toolbar=no, menubar=no, scrollbars=no, resizable=no, location=no, directories=no, status=no'
  return true  # don't return window since it makes angular sad

window.utils.get_share_dialog = _.curry2 open_share_dialog
