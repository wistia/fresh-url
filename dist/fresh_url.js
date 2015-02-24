var FreshUrl;

FreshUrl = (function() {
  FreshUrl.libraries = {
    googleAnalytics: {
      present: function() {
        return window._gaq || window[window.GoogleAnalyticsObject];
      },
      ready: function(ready) {
        return FreshUrl.waitsFor(FreshUrl.libraries.googleAnalytics.present).then(function() {
          var ga;
          if (ga = window._gaq) {
            return ga.push(function() {
              return ready();
            });
          } else if (ga = window[window.GoogleAnalyticsObject]) {
            return ga(function() {
              return ready();
            });
          }
        });
      }
    },
    hubspot: {
      present: function() {
        return window._hsq || FreshUrl.scriptFrom(/\/\/(js\.hubspot\.com|js.hs-analytics\.net)/);
      },
      ready: function(ready) {
        return FreshUrl.waitsFor(function() {
          return window._hsq;
        }).then(function() {
          return _hsq.push(function() {
            return ready();
          });
        });
      }
    },
    clicky: {
      present: function() {
        return window.clicky || window.clicky_site_ids || FreshUrl.scriptFrom(/\/\/static\.getclicky\.com/);
      },
      ready: function(ready) {
        return FreshUrl.waitsFor(function() {
          return window.clicky_obj;
        }).then(ready);
      }
    },
    pardot: {
      present: function() {
        return window.piAId || window.piCId || FreshUrl.scriptContains(/\.pardot\.com\/pd\.js/);
      },
      ready: function(ready) {
        return FreshUrl.waitsFor(function() {
          var _ref, _ref1;
          return (_ref = window.pi) != null ? (_ref1 = _ref.tracker) != null ? _ref1.url : void 0 : void 0;
        }).then(ready);
      }
    },
    simplex: {
      present: function() {
        return window.simplex || FreshUrl.scriptFrom(/\/simplex\.js/);
      },
      ready: function(ready) {
        return FreshUrl.waitsFor(function() {
          return window.simplex;
        }).then(ready);
      }
    },
    analyticsJs: {
      present: function() {
        var _ref;
        return (_ref = window.analytics) != null ? _ref.ready : void 0;
      },
      ready: function(ready) {
        return FreshUrl.waitsFor(function() {
          var _ref;
          return (_ref = window.analytics) != null ? _ref.ready : void 0;
        }).then(function() {
          return analytics.ready(ready);
        });
      }
    }
  };

  FreshUrl.originalUrl = window.location.href;

  function FreshUrl(waitList) {
    var iframeListener, item, _i, _len;
    if (waitList == null) {
      waitList = [];
    }
    if (!window.history.replaceState) {
      return;
    }
    this.key = 0;
    this._isReady = {};
    for (_i = 0, _len = waitList.length; _i < _len; _i++) {
      item = waitList[_i];
      if (typeof item === "string" && FreshUrl.libraries[item]) {
        this.wait(FreshUrl.libraries[item].ready, item);
      } else if (typeof item === "function") {
        this.wait(item);
      } else {
        if (typeof console !== "undefined" && console !== null) {
          console.log("FreshURL: Don't know how to wait for " + item);
        }
      }
    }
    if (waitList.length === 0) {
      if (this.allReady()) {
        this.allReadyCallback();
      }
    }
    FreshUrl.updateWistiaIframes();
    iframeListener = function(event) {
      if (event.data === 'new-wistia-iframe') {
        return FreshUrl.updateWistiaIframes();
      }
    };
    if (typeof window !== "undefined" && window !== null) {
      window.addEventListener('message', iframeListener, false);
    }
  }

  FreshUrl.prototype.wait = function(trigger, key) {
    if (key == null) {
      key = this.nextKey();
    }
    this._isReady[key] = false;
    return trigger((function(_this) {
      return function() {
        return _this.ready(key);
      };
    })(this));
  };

  FreshUrl.prototype.ready = function(key) {
    this._isReady[key] = true;
    if (this.allReady()) {
      return this.allReadyCallback();
    }
  };

  FreshUrl.prototype.allReady = function() {
    var key, notReady, value, _ref;
    notReady = [];
    _ref = this._isReady;
    for (key in _ref) {
      value = _ref[key];
      if (!value) {
        notReady.push(key);
      }
    }
    return notReady.length === 0;
  };

  FreshUrl.prototype.allReadyCallback = function() {
    return window.history.replaceState({}, '', FreshUrl.cleanUrl());
  };

  FreshUrl.cleanUrl = function() {
    var cleanSearch;
    cleanSearch = window.location.search.replace(/utm_[^&]+&?/g, '').replace(/(wkey|wemail)[^&]+&?/g, '').replace(/&$/, '').replace(/^\?$/, '');
    return window.location.pathname + cleanSearch + window.location.hash;
  };

  FreshUrl.poll = function(cond, callback, interval, timeout) {
    var pollFn, pollTimeout, start;
    if (interval == null) {
      interval = 50;
    }
    if (timeout == null) {
      timeout = 5000;
    }
    pollTimeout = null;
    start = new Date().getTime();
    pollFn = function() {
      if (new Date().getTime() - start > timeout) {
        return;
      }
      if (cond()) {
        return callback();
      } else {
        clearTimeout(pollTimeout);
        return pollTimeout = setTimeout(pollFn, interval);
      }
    };
    return pollTimeout = setTimeout(pollFn, 1);
  };

  FreshUrl.waitsFor = function(cond) {
    return {
      then: function(callback) {
        return FreshUrl.poll(cond, callback);
      }
    };
  };

  FreshUrl.prototype.nextKey = function() {
    return this.key += 1;
  };

  FreshUrl.scriptFrom = function(re) {
    var script, _i, _len, _ref, _ref1;
    _ref = document.getElementsByTagName('script');
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      script = _ref[_i];
      if ((_ref1 = script.getAttribute('src')) != null ? _ref1.match(re) : void 0) {
        return true;
      }
    }
    return false;
  };

  FreshUrl.scriptContains = function(re) {
    var script, _i, _len, _ref, _ref1;
    _ref = document.getElementsByTagName('script');
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      script = _ref[_i];
      if ((_ref1 = script.innerHTML) != null ? _ref1.match(re) : void 0) {
        return true;
      }
    }
    return false;
  };

  FreshUrl.librariesPresent = function() {
    var library, name, _ref, _results;
    _ref = FreshUrl.libraries;
    _results = [];
    for (name in _ref) {
      library = _ref[name];
      if (library.present()) {
        _results.push(name);
      }
    }
    return _results;
  };

  FreshUrl.wistiaIframes = function() {
    var iframe, _i, _len, _ref, _results;
    _ref = document.getElementsByTagName('iframe');
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      iframe = _ref[_i];
      if (iframe.src.match(/\/\/.*\.wistia\..*\//)) {
        _results.push(iframe);
      }
    }
    return _results;
  };

  FreshUrl.updateWistiaIframes = function() {
    var e, iframe, message, _i, _len, _ref, _results;
    message = {
      method: 'updateProperties',
      args: [
        {
          params: {
            pageUrl: this.originalUrl
          },
          options: {
            pageUrl: this.originalUrl
          }
        }
      ]
    };
    _ref = this.wistiaIframes();
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      iframe = _ref[_i];
      try {
        _results.push(iframe.contentWindow.postMessage(message, '*'));
      } catch (_error) {
        e = _error;
      }
    }
    return _results;
  };

  return FreshUrl;

})();

if (typeof _freshenUrlAfter !== "undefined" && _freshenUrlAfter !== null) {
  window.freshUrl = new FreshUrl(_freshenUrlAfter);
} else if (window.dataLayer) {
  dataLayer.push(function() {
    return window.freshUrl = new FreshUrl(FreshUrl.librariesPresent());
  });
} else {
  window.freshUrl = new FreshUrl(FreshUrl.librariesPresent());
}
