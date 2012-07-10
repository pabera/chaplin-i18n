I18n - Localization for Chaplin
===============================

This is a small localization library for (Chaplin)[https://github.com/chaplinjs/chaplin]. As soon as I am finished with it I'll try to propose it as a pull request since it might be useful in general.

### Configuration

## Requirements

Since it has not been included directly into Chaplin yet you need to clone this repository, compile it and save the file to you `js/lib` folder like the `utils.js` coming with Chaplin assuming you are using the (Chaplin-Boilerplate)[https://github.com/chaplinjs/chaplin-boilerplate]. Well this is pretty much it.

To get the localization to work, just require the library in your application file and call the `init()` method.


````
define [
  'chaplin'
  ...
  'routes'
  'lib/i18n'
], (Chaplin, ..., routes, I18n) ->
  'use strict'

  # The application object
  class HelloWorldApplication extends Chaplin.Application

    initialize: ->
      super

      # Initialize i18n for Chaplin
      I18n.init()

      ....

      Object.freeze? this
````

At the moment, setting a global variable is the only way to set a language. Please add the following snippet to your index.html

````
  <script>window.__locale = "de"</script>
````

I haven't been able to test all this using large localization files. I am a bit concerned about having a performance loss. Right now, *English* (`en`) is the default langauge.

## Localizations

Furthermore you obviously need some localizations. You support as many langugaes as you want. Just create a `js/locale` folder where you put your language files. This files will be saved as JSON and are called like this `en.json` or `de.json`.

The JSON langauge file will look like this - you can find an example in this repo as well.

````
{
  "de" : 
  {
    "Hello World": "Hallo Welt",
    "My name is {0}, I am {1} years old and I love Chaplin.": "Mein Name ist {0}, ich bin {1} Jahre alt und ich liebe Chaplin.",
  }
}

````

## Usage in Handlebars Templates

It is important to understand that you don't need any localization file for your default language since you directly use the strings in your Handlebars Templates.

To use your I18n in your templates, please wrap you string to be translated like this (Attention: I am using HAML templates!)

````
%h1 {{ t "Hello World" }}
%p {{ t "My name is {0}, I am {1} years old and I love Chaplin." name age }}
````

The `t` method is a Handlebars-Helper registered by the the library. It can then 'translate' simple strings but also complete sentences where you need to inject even more variables. Just append the corresponding arguments to the method call after the string to be translated and the library will inject the arguments correctly.