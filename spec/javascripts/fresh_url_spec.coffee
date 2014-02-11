describe 'FreshUrl', ->

  it 'is defined', ->
    expect(typeof FreshUrl isnt 'undefined').to.be.true


  describe 'the whole enchilada', ->
    beforeEach ->
      @_originalUrl = window.location.href
      @cleanUrl = @_originalUrl.replace(/\?.*$/, '')
      @cleanPath = window.location.pathname
      dirtyPath = "#{@cleanPath}?utm_medium=specs&utm_source=jasmine&wemail=my@email.com"
      window.history.replaceState({}, '', dirtyPath)
      @dirtyUrl = window.location.href

    afterEach ->
      window.history.replaceState({}, '', @_originalUrl)


    it 'cleans dirty URLs where\'s there\'s nothing to wait for', ->
      new FreshUrl()
      expect(window.location.href).to.equal(@cleanUrl)


    it 'cleans dirty URLs where\'s there\'s something to wait for', ->
      tReady = null
      t = (ready) -> tReady = ready
      new FreshUrl([t])
      expect(window.location.href).to.equal(@dirtyUrl)
      tReady()
      expect(window.location.href).to.equal(@cleanUrl)


    it 'sets FreshUrl.originalUrl to the original page URL', ->
      expect(FreshUrl.originalUrl).to.equal(@_originalUrl)


    it 'does nothing when the client doesn\'t support replaceState', ->
      replaceState = window.history.replaceState
      window.history.replaceState = undefined
      new FreshUrl()
      expect(window.location.href).to.equal(@dirtyUrl)
      window.history.replaceState = replaceState



  describe '.allReadyCallback', ->
    afterEach ->
      window.simplex = undefined

    it 'waits for a named trigger', (done) ->
      f = new FreshUrl(['simplex'])
      f.allReadyCallback = done
      setTimeout((-> window.simplex = 'hi'), 50)

    it 'waits for a custom trigger', (done) ->
      trigger = (ready) -> setTimeout((-> ready()), 50)
      f = new FreshUrl([trigger])
      f.allReadyCallback = done

    it 'waits for both a named and custom trigger', (done) ->
      trigger = (ready) -> setTimeout((-> ready()), 50)
      f = new FreshUrl(['simplex', trigger])
      f.allReadyCallback = done
      setTimeout((-> window.simplex = 'hi'), 50)

    it 'waits for all triggers to be ready', (done) ->
      fastTrigger = (ready) -> ready()
      slowTrigger = (ready) -> setTimeout((-> ready()), 50)
      f = new FreshUrl([fastTrigger, slowTrigger])
      f.allReadyCallback = done
      expect(f.allReady()).to.be.false


  describe '.allReady', ->

    it 'is true if there\'s nothing to wait for', ->
      f = new FreshUrl()
      expect(f.allReady()).to.be.true

    it 'is false if there\'s something to wait for and it\'s not ready', ->
      f = new FreshUrl(['simplex'])
      expect(f.allReady()).to.be.false

    it 'is true when everything is ready', ->
      t1Ready = null
      t2Ready = null
      t1 = (ready) -> t1Ready = ready
      t2 = (ready) -> t2Ready = ready
      f = new FreshUrl([t1, t2])
      expect(f.allReady()).to.be.false
      t1Ready()
      expect(f.allReady()).to.be.false
      t2Ready()
      expect(f.allReady()).to.be.true


  describe '.waitsFor', ->
    it 'doesn\'t execute the callback when the condition function is not met', ->
      callback = false
      FreshUrl.waitsFor(-> false).then(-> callback = true)
      expect(callback).to.be.false

    it 'executes the callback when the condition function is met', (done) ->
      doneWaiting = false
      setTimeout((-> doneWaiting = true), 50)
      FreshUrl.waitsFor(-> doneWaiting is true).then(done)


  describe '#cleanedSearch', ->
    f = new FreshUrl()
    expectClean = (before, after) ->
      expect(f.cleanedSearch(before)).to.equal(after)

    it 'leaves non-utm params', ->
      expectClean('?utm_medium=email&hello=you',
                  '?hello=you')
      expectClean('?cat=dog&utm_medium=email&hello=you&utm_source=whatevs',
                  '?cat=dog&hello=you')

    it 'wipes everything if there are only utm params', ->
      expectClean('?utm_medium=email&utm_source=okokok', '')

    it 'eliminates wemail and wkey params', ->
      expectClean('?wemail=brendan@wistia.com&hello=goodbye', '?hello=goodbye')
      expectClean('?wkey=XfxcFt3422', '')


  describe 'Wistia iframes', ->
    window.iframes = []

    createIframe = (src) ->
      iframe = document.createElement('iframe')
      iframe.src = src
      iframe.width = 1
      iframe.height = 1
      document.body.appendChild(iframe)
      window.iframes.push(iframe)

    afterEach ->
      while iframe = window.iframes.pop()
        document.body.removeChild(iframe)


    it 'calls updateWistiaIframes when a new Wistia iframe appears', (done) ->
      spy = sinon.spy(FreshUrl, 'updateWistiaIframes')
      createIframe('//fast.wistia.net/embed/iframe/7e37782c2c')
      FreshUrl.waitsFor(-> spy.called).then(done)


    describe '.wistiaIFrames', ->
      it 'returns only wistia iframes', ->
        createIframe('https://fast.wistia.net/embed/iframe/7e37782c2c')
        createIframe('https://google.com')
        expect(FreshUrl.wistiaIframes().length).to.equal(1)
