# Fresh URL

When a visitor clicks through from one of your emails, tweets, or ads, they'll
likely have UTM codes in the query string of the URL. You've seen them before,
they look like this:

```
http://wistia.com/blog/top-hat-tips-dont-light-from-below?utm_content=buffer2ba10&utm_medium=social&utm_source=twitter.com&utm_campaign=buffer
```

Yuck!

Fresh URL automatically coordinates with the analytics services you're using on 
your page and eliminates the UTM clutter from your URL.

Your visitors get fresh, clean URLs, and you get clean analytics data!


## How do I use it?

Include this JavaScript at the bottom of your page:

```html
<script src="//fast.wistia.net/labs/fresh-url/v1.js" async></script>
```

## How does it work?

Fresh URL will automatically try to figure out what analytics scripts you have
running on your page, and make sure to strip the UTM codes out _after_ those
scripts have done their thing.

Right now, Fresh URL supports these libraries:

- [Google Analytics](http://www.google.com/analytics) (googleAnalytics): works with both ga.js and analytics.js
- [Pardot](http://pardot.com) (pardot): Salesforce's sales automation product
- [HubSpot](http://hubspot.com) (hubspot): Boston-based marketing automation
- [Clicky](http://clicky.com) (clicky): Realtime web analytics
- [Analytics.js] (analyticsJs): Segment.io's universal analytics solution


## Configuration

If you'd rather explicitly specify what analytics libraries you're using
rather than having Fresh URL detect them, just do this:

```html
<script>
  var _freshenUrlAfter = ['googleAnalytics', 'pardot', 'hubspot'];
</script>
<script src="//fast.wistia.net/labs/fresh-url/v1.js" async></script>
```

### Custom Triggers

If you're using libraries that aren't supported out of the box, it's easy to
have Fresh URL wait for custom conditions to be met before cleaning the URL.

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
<script src="//fast.wistia.net/labs/fresh-url/v1.js" async></script>
```

Fresh URL passes a `ready` function to the trigger function. When that trigger
is ready, call that function.


## The API

If you're creating custom triggers and integrating with other services, you
may find these functions useful.


### FreshUrl.originalUrl

Want access to the raw original URL? It's available at `FreshUrl.originalUrl`.


### FreshUrl.waitsFor

`FreshUrl.waitsFor` is a useful method for waiting for some condition to be
met. It works like this:

```javascript
FreshUrl.waitsFor(conditionFn).then(callbackFn)
```

When you call this, Fresh URL will poll the `conditionFn`. As soon as it returns
true, the `callbackFn` will be run. Under the covers, `waitsFor` uses `FreshUrl.poll`.


### FreshUrl.poll

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



## Bonus Features

### Google Tag Manager

Fresh URL plays nicely with Google Tag Manager. It automatically detects if
you're using Google Tag Manager and delays its automatic detection of your
JavaScript libraries until after GTM has initialized.

It accomplishes this by pushing a function onto the `dataLayer`. That function
is executed after your scripts are dumped into the DOM, but before they've run.


### Wistia-specific URL parameters

Fresh URL automatically scrubs `wemail` and `wkey` from the URL as well.
Isn't that nice? There's nothing worse than someone sharing a link with their
`wemail` in the query string and having multiple visitors tagged with the same
email address in your stats!


## Troubleshooting


### UTM codes are not being removed from the URL

Have the script on your page, but it's not clearing the UTM codes?
It's probably detecting that you're using a particular library but not able
to detect that it's ready.

Try checking out `freshUrl._isReady` in the console and see what it returns.

Also, if you're using an older browser (like IE8 or 9), this won't work. Fresh
URL needs `history.replaceState` functionality to do its thing.

The other possibility is that you have some slow loading scripts on your page.
By default, Fresh URL will give up if a library takes longer than 5 seconds to
load. HubSpot and Pardot both don't send tracking info until onload fires on the
page. If you have lots of slow loading assets on your page, this might cause
Fresh URL to timeout while waiting for them.


### UTM related information is no longer showing up in my analytics

If the analytics service you're using is not officially supported by Fresh URL,
then what's likely happening is that Fresh URL is removing the UTM codes from the
page URL before your analytics library gets a chance to report them.

Open an issue, and we'll try to add support for it. Or better yet, add support
and submit a pull request!


## Development

Fresh URL is written in CoffeeScript and uses
[Jasmine](http://jasmine.github.io/2.0/introduction.html) for testing.


### Setup

1. Clone this repository.
2. Make sure you have Ruby installed.
3. Install CoffeeScript: `brew install node` and `npm install -g coffee-script`
4. Install Uglifier: `npm install -g uglify-js`
4. Install the required gems: `bundle install`


### Running the Specs

Fresh URL uses [Foreman](https://github.com/ddollar/foreman) to run the specs,
compile the CoffeeScript, and uglify the JavaScript.

`foreman start` and then go to `http://localhost:8888/` in your browser to
run the specs.


### Minifying for release

The minified version lives in `dist/fresh_url.js`. As long as you're running
foreman, guard will automatically be minifying the JavaScript and updating the
file in `dist` for you.


## MIT License

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
