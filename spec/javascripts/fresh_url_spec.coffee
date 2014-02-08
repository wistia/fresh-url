describe 'FreshUrl', ->

  it 'is defined', ->
    expect(typeof FreshUrl isnt 'undefined').toBe(true)


  describe 'the whole enchilada', ->
    beforeEach ->
      @_originalUrl = window.location.href
      @cleanUrl = @_originalUrl.replace(/\?.*$/, '')
      @cleanPath = window.location.pathname
      dirtyUrl = "#{@cleanPath}?utm_medium=specs&utm_source=jasmine"
      window.history.replaceState({}, '', dirtyUrl)
      @dirtyUrl = window.location.href

    afterEach ->
      window.history.replaceState({}, '', @_originalUrl)


    it 'cleans dirty URLs where\'s there\'s nothing to wait for', ->
      new FreshUrl()
      expect(window.location.href).toBe(@cleanUrl)


    it 'cleans dirty URLs where\'s there\'s something to wait for', ->
      tReady = null
      t = (ready) -> tReady = ready
      new FreshUrl([t])
      expect(window.location.href).toBe(@dirtyUrl)
      tReady()
      expect(window.location.href).toBe(@cleanUrl)


    it 'sets FreshUrl.originalUrl to the original page URL', ->
      expect(FreshUrl.originalUrl).toBe(@_originalUrl)


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
      expect(f.allReady()).toBe(false)


  describe '.allReady', ->

    it 'is true if there\'s nothing to wait for', ->
      f = new FreshUrl()
      expect(f.allReady()).toBe(true)

    it 'is false if there\'s something to wait for and it\'s not ready', ->
      f = new FreshUrl(['simplex'])
      expect(f.allReady()).toBe(false)

    it 'is true when everything is ready', ->
      t1Ready = null
      t2Ready = null
      t1 = (ready) -> t1Ready = ready
      t2 = (ready) -> t2Ready = ready
      f = new FreshUrl([t1, t2])
      expect(f.allReady()).toBe(false)
      t1Ready()
      expect(f.allReady()).toBe(false)
      t2Ready()
      expect(f.allReady()).toBe(true)


  describe '.waitsFor', ->
    it 'doesn\'t execute the callback when the condition function is not met', ->
      callback = false
      FreshUrl.waitsFor(-> false).then(-> callback = true)
      expect(callback).toBe(false)

    it 'executes the callback when the condition function is met', (done) ->
      doneWaiting = false
      setTimeout((-> doneWaiting = true), 50)
      FreshUrl.waitsFor(-> doneWaiting is true).then(done)


  describe '#cleanedSearch', ->
    f = new FreshUrl()
    expectClean = (before, after) ->
      expect(f.cleanedSearch(before)).toBe(after)

    it 'leaves non-utm params', ->
      expectClean('?utm_medium=email&hello=you',
                  '?hello=you')
      expectClean('?cat=dog&utm_medium=email&hello=you&utm_source=whatevs',
                  '?cat=dog&hello=you')

    it 'wipes everything if there are only utm params', ->
      expectClean('?utm_medium=email&utm_source=okokok', '')
