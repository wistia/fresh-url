describe('FreshUrl', function() {
  it('is defined', function() {
    return expect(typeof FreshUrl !== 'undefined').toBe(true);
  });
  describe('the whole enchilada', function() {
    beforeEach(function() {
      var dirtyUrl;
      this._originalUrl = window.location.href;
      this.cleanUrl = this._originalUrl.replace(/\?.*$/, '');
      this.cleanPath = window.location.pathname;
      dirtyUrl = "" + this.cleanPath + "?utm_medium=specs&utm_source=jasmine&wemail=my@email.com";
      window.history.replaceState({}, '', dirtyUrl);
      return this.dirtyUrl = window.location.href;
    });
    afterEach(function() {
      return window.history.replaceState({}, '', this._originalUrl);
    });
    it('cleans dirty URLs where\'s there\'s nothing to wait for', function() {
      new FreshUrl();
      return expect(window.location.href).toBe(this.cleanUrl);
    });
    it('cleans dirty URLs where\'s there\'s something to wait for', function() {
      var t, tReady;
      tReady = null;
      t = function(ready) {
        return tReady = ready;
      };
      new FreshUrl([t]);
      expect(window.location.href).toBe(this.dirtyUrl);
      tReady();
      return expect(window.location.href).toBe(this.cleanUrl);
    });
    return it('sets FreshUrl.originalUrl to the original page URL', function() {
      return expect(FreshUrl.originalUrl).toBe(this._originalUrl);
    });
  });
  describe('.allReadyCallback', function() {
    afterEach(function() {
      return window.simplex = void 0;
    });
    it('waits for a named trigger', function(done) {
      var f;
      f = new FreshUrl(['simplex']);
      f.allReadyCallback = done;
      return setTimeout((function() {
        return window.simplex = 'hi';
      }), 50);
    });
    it('waits for a custom trigger', function(done) {
      var f, trigger;
      trigger = function(ready) {
        return setTimeout((function() {
          return ready();
        }), 50);
      };
      f = new FreshUrl([trigger]);
      return f.allReadyCallback = done;
    });
    it('waits for both a named and custom trigger', function(done) {
      var f, trigger;
      trigger = function(ready) {
        return setTimeout((function() {
          return ready();
        }), 50);
      };
      f = new FreshUrl(['simplex', trigger]);
      f.allReadyCallback = done;
      return setTimeout((function() {
        return window.simplex = 'hi';
      }), 50);
    });
    return it('waits for all triggers to be ready', function(done) {
      var f, fastTrigger, slowTrigger;
      fastTrigger = function(ready) {
        return ready();
      };
      slowTrigger = function(ready) {
        return setTimeout((function() {
          return ready();
        }), 50);
      };
      f = new FreshUrl([fastTrigger, slowTrigger]);
      f.allReadyCallback = done;
      return expect(f.allReady()).toBe(false);
    });
  });
  describe('.allReady', function() {
    it('is true if there\'s nothing to wait for', function() {
      var f;
      f = new FreshUrl();
      return expect(f.allReady()).toBe(true);
    });
    it('is false if there\'s something to wait for and it\'s not ready', function() {
      var f;
      f = new FreshUrl(['simplex']);
      return expect(f.allReady()).toBe(false);
    });
    return it('is true when everything is ready', function() {
      var f, t1, t1Ready, t2, t2Ready;
      t1Ready = null;
      t2Ready = null;
      t1 = function(ready) {
        return t1Ready = ready;
      };
      t2 = function(ready) {
        return t2Ready = ready;
      };
      f = new FreshUrl([t1, t2]);
      expect(f.allReady()).toBe(false);
      t1Ready();
      expect(f.allReady()).toBe(false);
      t2Ready();
      return expect(f.allReady()).toBe(true);
    });
  });
  describe('.waitsFor', function() {
    it('doesn\'t execute the callback when the condition function is not met', function() {
      var callback;
      callback = false;
      FreshUrl.waitsFor(function() {
        return false;
      }).then(function() {
        return callback = true;
      });
      return expect(callback).toBe(false);
    });
    return it('executes the callback when the condition function is met', function(done) {
      var doneWaiting;
      doneWaiting = false;
      setTimeout((function() {
        return doneWaiting = true;
      }), 50);
      return FreshUrl.waitsFor(function() {
        return doneWaiting === true;
      }).then(done);
    });
  });
  describe('#cleanedSearch', function() {
    var expectClean, f;
    f = new FreshUrl();
    expectClean = function(before, after) {
      return expect(f.cleanedSearch(before)).toBe(after);
    };
    it('leaves non-utm params', function() {
      expectClean('?utm_medium=email&hello=you', '?hello=you');
      return expectClean('?cat=dog&utm_medium=email&hello=you&utm_source=whatevs', '?cat=dog&hello=you');
    });
    it('wipes everything if there are only utm params', function() {
      return expectClean('?utm_medium=email&utm_source=okokok', '');
    });
    return it('eliminates wemail and wkey params', function() {
      expectClean('?wemail=brendan@wistia.com&hello=goodbye', '?hello=goodbye');
      return expectClean('?wkey=XfxcFt3422', '');
    });
  });
  return describe('Wistia iframes', function() {
    var createIframe;
    window.iframes = [];
    createIframe = function(src) {
      var iframe;
      iframe = document.createElement('iframe');
      iframe.src = src;
      iframe.width = 1;
      iframe.height = 1;
      document.body.appendChild(iframe);
      return window.iframes.push(iframe);
    };
    afterEach(function() {
      var iframe, _results;
      _results = [];
      while (iframe = window.iframes.pop()) {
        _results.push(document.body.removeChild(iframe));
      }
      return _results;
    });
    it('calls updateWistiaIframes when a new Wistia iframe appears', function(done) {
      spyOn(FreshUrl, 'updateWistiaIframes');
      createIframe('https://fast.wistia.net/embed/iframe/7e37782c2c');
      return FreshUrl.waitsFor(function() {
        return FreshUrl.updateWistiaIframes.calls.any();
      }).then(done);
    });
    return describe('.wistiaIFrames', function() {
      return it('returns only wistia iframes', function() {
        createIframe('https://fast.wistia.net/embed/iframe/7e37782c2c');
        createIframe('https://google.com');
        return expect(FreshUrl.wistiaIframes().length).toBe(1);
      });
    });
  });
});
