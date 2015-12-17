class FreshUrl

  @libraries:
    googleAnalytics:
      present: -> window._gaq or window[window.GoogleAnalyticsObject]
      ready: (ready) ->
        FreshUrl.waitsFor(FreshUrl.libraries.googleAnalytics.present).then(->
          if ga = window._gaq
            ga.push(-> ready())
          else if ga = window[window.GoogleAnalyticsObject]
            ga(-> ready())
        )

    hubspot:
      present: -> window._hsq or FreshUrl.scriptFrom(/\/\/(js\.hubspot\.com|js.hs-analytics\.net)/)
      ready: (ready) -> FreshUrl.waitsFor(-> window._hsq).then(-> _hsq.push(-> ready()))

    clicky:
      present: -> window.clicky or window.clicky_site_ids or FreshUrl.scriptFrom(/\/\/static\.getclicky\.com/)
      ready: (ready) -> FreshUrl.waitsFor(-> window.clicky_obj).then(ready)

    pardot:
      present: -> window.piAId or window.piCId or FreshUrl.scriptContains(/\.pardot\.com\/pd\.js/)
      ready: (ready) -> FreshUrl.waitsFor(-> window.pi?.tracker?.url).then(ready)

    simplex:
      present: -> window.simplex or FreshUrl.scriptFrom(/\/simplex\.js/)
      ready: (ready) -> FreshUrl.waitsFor(-> window.simplex).then(ready)

    analyticsJs:
      present: -> window.analytics?.ready
      ready: (ready) -> FreshUrl.waitsFor(-> window.analytics?.ready).then(-> analytics.ready(ready))


  # Save the original URL for convenience
  @originalUrl: window.location.href


  # give this thing a list of strings and trigger functions to wait for
  # before cleaning the URL
  constructor: (waitList = []) ->
    # if the client doesn't support replaceState, don't bother with anything here.
    return unless window.history.replaceState

    @key = 0
    @_isReady = {}

    for item in waitList
      if typeof item is "string" and FreshUrl.libraries[item]
        @wait(FreshUrl.libraries[item].ready, item)
      else if typeof item is "function"
        @wait(item)
      else
        console?.log "FreshURL: Don't know how to wait for #{item}"

    # if there's nothing to wait for, we're ready!
    if waitList.length is 0
      @allReadyCallback() if @allReady()

    # update all Wistia iframes
    FreshUrl.updateWistiaIframes()

    # listen for future Wistia iframes so we can make sure to update their pageUrls
    iframeListener = (event) ->
      FreshUrl.updateWistiaIframes() if event.data is 'new-wistia-iframe'
    window?.addEventListener 'message', iframeListener, false


  wait: (trigger, key) ->
    key ?= @nextKey()
    @_isReady[key] = false
    trigger(=> @ready(key))


  ready: (key) ->
    @_isReady[key] = true
    @allReadyCallback() if @allReady()


  # returns true if all the values in _analyticsReady are true
  allReady: ->
    notReady = []
    for key, value of @_isReady
      notReady.push(key) unless value
    notReady.length is 0


  allReadyCallback: ->
    window.history.replaceState({}, '', FreshUrl.cleanUrl())


  @cleanUrl: ->
    cleanSearch = window.location.search.
        replace(/utm_[^&]+&?/g, '').           # no UTM codes
        replace(/(wkey|wemail)[^&]+&?/g, '').  # no wkey, wemail
        replace(/(_hsenc|_hsmi)[^&]+&?/g, '').  # no hubspot params
        replace(/&$/, '').
        replace(/^\?$/, '')

    window.location.pathname + cleanSearch + window.location.hash


  @poll: (cond, callback, interval = 50, timeout = 5000) ->
      pollTimeout = null
      start = new Date().getTime()
      pollFn = ->
        return if new Date().getTime() - start > timeout
        if cond()
          callback()
        else
          clearTimeout(pollTimeout)
          pollTimeout = setTimeout(pollFn, interval)

      pollTimeout = setTimeout(pollFn, 1)


  # FreshUrl.waitsFor(conditionFn).then(callbackFn)
  @waitsFor: (cond) ->
    then: (callback) ->
      FreshUrl.poll(cond, callback)


  nextKey: ->
    @key += 1


  # FreshUrl.scriptFrom(/\/\/fast\.wistia\.com/)
  #
  # Returns true if there's a script whose src matches the supplied regex.
  @scriptFrom: (re) ->
    for script in document.getElementsByTagName('script')
      return true if script.getAttribute('src')?.match(re)
    false

  # FreshUrl.scriptContains(/pardot\.com/)
  #
  # Returns true if there's a script block whose contents matches the supplied
  # regex.
  @scriptContains: (re) ->
    for script in document.getElementsByTagName('script')
      return true if script.innerHTML?.match(re)
    false

  # Returns the names of libraries that it thinks are present on the page
  @librariesPresent: ->
    name for name, library of FreshUrl.libraries when library.present()


  # Returns all Wistia iframes on the page
  @wistiaIframes: ->
    iframe for iframe in document.getElementsByTagName('iframe') when iframe.src.match(/\/\/.*\.wistia\..*\//)


  # Posts the originalUrl to all Wistia iframes on the page
  @updateWistiaIframes: ->
    message =
      method: 'updateProperties'
      args: [
        params: { pageUrl: @originalUrl }
        options: { pageUrl: @originalUrl }
      ]

    for iframe in @wistiaIframes()
      try
        iframe.contentWindow.postMessage message, '*'
      catch e
        # oh well, we tried





if _freshenUrlAfter?
  # oh, you want to wait for specific libraries, okay!
  window.freshUrl = new FreshUrl(_freshenUrlAfter)
else if window.dataLayer
  # GTM is present, delay autodetection until after it's loaded
  dataLayer.push(-> window.freshUrl = new FreshUrl(FreshUrl.librariesPresent()))
else
  # detect what's on the page, and wait for those libraries
  window.freshUrl = new FreshUrl(FreshUrl.librariesPresent())

