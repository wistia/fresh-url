# Fresh URL

Tired of nasty UTM codes nesting in your URLs? Sick of your web traffic getting
attributed to the wrong sources? You need Fresh URL.


# What's it do?

When a visitor clicks through from one of your email campaigns, tweets, what
have you, they'll likely have UTM codes in the query string of the URL.

Fresh URL coordinates with your third party analytics libraries and then
eliminates the UTM clutter from your URL.

Your visitors get fresh, clean URLs and you get clean analytics data.


# How do I use it?

Include this JavaScript on your page:

```html
<script src="//fast.wistia.net/assets/external/fresh-url.js" async></script>
```


# How does it work?

Fresh URL will automatically try to figure out what analytics scripts you have
running on your page, and make sure to strip the UTM codes out _after_ those
scripts have done their thing.

Of course, this automatic detection is not perfect, especially if you're using
something like Google Tag Manager.

In this case, you can tell Fresh URL exactly what tracking libraries you're
using, and it will wait for those libraries to become available.


# Configuration

To specify which libraries you want Fresh URL to wait for, just do this:

```html
<script>
  var _freshenUrlAfter = ['googleAnalytics', 'pardot', 'hubspot'];
</script>
<script src="//fast.wistia.net/assets/external/fresh-url.js" async></script>
```

Right now, Fresh URL knows how to wait for the following libraries:

- [Google Analytics](http://www.google.com/analytics) (googleAnalytics): works with both ga.js and analytics.js
- [Pardot](http://pardot.com) (pardot): Salesforce's sales automation product
- [HubSpot](http://hubspot.com) (hubspot): Boston-based marketing automation
- [Clicky](http://clicky.com) (clicky): Realtime web analytics
- [Analytics.js] (analyticsJs): Segment.io's universal analytics solution


# Custom Triggers

It's easy to have Fresh URL wait for other triggers before cleaning the URL.
Say we want to wait for the variable `myLib` to be available.  Just add a
function into the `_freshenUrlAfter` array:

```html
<script>
  var myTrigger = function(ready){
    // poll for the variable myLib, when that's ready, we're ready!
    FreshUrl.waitsFor(function(){ window.myLib }).then(ready)
  };
  var _freshenUrlAfter = ['googleAnalytics', myTrigger];
</script>
<script src="//fast.wistia.net/assets/external/fresh-url.js" async></script>
```

Fresh URL passes a `ready` function to the trigger function. When that trigger
is ready, call that function.


# The API

## FreshUrl.waitsFor

`FreshUrl.waitsFor` is a useful method for waiting for some condition to be
met. It works like this:

```javascript
FreshUrl.waitsFor(conditionFn).then(callbackFn)
```

When you call this, Fresh URL will poll the `conditionFn`. As soon as it returns
true, the `callbackFn` will be run. Under the covers, `waitsFor` uses `FreshUrl.poll`.


## FreshUrl.poll

If you need finer grained control while waiting for some condition to be met
The `FreshUrl.poll` method is pretty handy if you're waiting for some variable
to appear on the page. It works like this:

```javascript
freshUrl.poll(
  conditionFn,
  callbackFn,
  interval,
  timeout
)
```

`conditionFn` is the function that will be evaluated repeatedly. It should return
true or false. When it returns true, `callbackFn` will be run. When it returns
false, it will be run again and again until it return true or the timeout is hit.

`interval` is how frequently to evaluate the `conditionFn` in milliseconds. It
defaults to 50ms.

`timeout` is how long in milliseconds it will continue poll that `conditionFn`
before giving up. It defaults to 5 seconds.


## FreshUrl.originalUrl

Want access to the raw original URL? It's in `FreshUrl.originalUrl`.


# Bonus Features

## Google Tag Manager

Fresh URL plays nicely with Google Tag Manager. It automatically detects if
you're using Google Tag Manager and delays its automatic detection of your
JavaScript libraries until after GTM has initialized.

It accomplishes this by pushing a function onto the `dataLayer`. That function
is executed after your scripts are dumped into the DOM, but before they've run.


## Wistia-specific URL parameters

Fresh URL automatically scrubs `wemail` and `wkey` from the URL as well.
Isn't that nice? There's nothing worse than someone sharing a link with their
`wemail` in the query string and having lots of visitors tagged with the same
email!


# Troubleshooting

Have the script on your page but it's not clearing the UTM codes?
It's probably detecting that you're using a particular library but not able
to register that it's ready.

Try checking out `freshUrl._isReady` in the console and see what it returns.


# MIT License

Copyright (C) 2014 Wistia, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
