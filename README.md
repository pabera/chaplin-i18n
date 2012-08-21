 chaplin-i18n - Localization for Chaplin
========================================

This is a small localization library for [Chaplin](https://github.com/chaplinjs/chaplin).

### Stuff, we can do today

handlebars helper method
* use a real [basic translation method](#usage-in-handlebars-templates) to handle your localization

basic gettext support
* Create POT files from your given source
* export translated PO files to a JSON format which the chaplin-i18n plugin understands

*Todos*
* read MO files?!
* use [BCP 47 language tags](http://www.rfc-editor.org/bcp/bcp47.txt)
* add more lingual helpers such as pluralize or singularize
* Currently there is no way to set the language within your application. This is pretty unusable and I really need to fix it since it is the main feature.
* make this plugin more independent from chaplin (and handlebars templating engine)
* implementing new [ECMAScript Internationalization API](http://wiki.ecmascript.org/doku.php?id=globalization:specification_drafts)

*Attention:*
* This is still work in progress ;) Any contributions appreciated ...

## Configuration

### Requirements

Since this is just a plugin for Chaplin you need to clone this repository, compile it and save the file to you `js/lib` folder like the `utils.js` coming with Chaplin assuming you are using the [Chaplin-Boilerplate](https://github.com/chaplinjs/chaplin-boilerplate). This is important because, in the `views/base/view.coffee` file you need to register a Handlebars Helper to use i18n in your Handlebars template. *chaplin-i18n* does not depend on Handlebars, just write your own wrappers to use the i18n lib with ECO or other template engines.

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

I haven't been able to test all this using large localization files. I am a bit concerned about having a performance loss. Right now, *English* (`en`) is the default language.

### Localizations

Furthermore you obviously need some localizations. You'll be able to support as many languages as you want. There are two possibilites to create your locales.

1. Just create a `js/locale` folder where you put your language files. This files will be saved as JSON and are called like this `en.json` or `de.json`. 
2. [Use the implemented parsers to create PO compatiple POT translation templates and PO to JSON parsers](#language-string-parsers)

The JSON language should be somehow similar to this snippet - you can find an example in this repo.

````
{
  "de" : 
  {
    "Hello World": "Hallo Welt",
    "My name is {0}, I am {1} years old and I love Chaplin.": "Mein Name ist {0}, ich bin {1} Jahre alt und ich liebe Chaplin.",
  }
}

````

### Usage in Handlebars Templates

It is important to understand that you don't need any localization file for your default language since you directly use the strings in your Handlebars Templates.

To use I18n, please wrap your string to be translated like this (I am using HAML templates here!)

````
%h1 {{ t "Hello World" }}
%p {{ t "My name is {0}, I am {1} years old and I love Chaplin." name age }}
````

The `t` method is a Handlebars-Helper registered by the the library. Then it is able to 'translate' simple strings but also complete sentences where you need to inject even more variables. Just append the corresponding arguments to the method call after the string and the library will inject the arguments correctly.

### Language string parsers

Set your configuration in the `bin/config.yml`

#### Template files to POT
*Currently, this only works for handlebars templates that use chaplin-i18n implementation. I will try to solve that.*

`ruby intl.rb [read]`

Now you get a POT output in your `./locales/` folder. Use this file to do your translations and put the PO (no MO support right now) in the same folder.

#### PO to chaplin-i18n JSON files

`ruby intl.rb write`