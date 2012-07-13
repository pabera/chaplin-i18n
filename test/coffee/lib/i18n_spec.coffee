# Spec for chaplin-i18n

define [
  'underscore'
  'chaplin'
  'lib/i18n'
  'text!../../fixtures/de.json'
], (_, Chaplin, i18n, de_json_fixture) ->
  'use strict'

  describe 'chaplin-i18n plugin', ->

    describe 'Basics', ->

      it 'should have a @__locale variable', ->
        expect(i18n.__locale).not.to.be.undefined
        expect(i18n.__locale).to.be.null

      it 'should have a @defaultLocale, default locale is "en"', ->
        expect(i18n.defaultLocale).to.be.a('string')
        expect(i18n.defaultLocale).to.equal('en')

      it 'should have a @localization', ->
        expect(i18n.localization).to.be.an('object')
        expect(i18n.localization).to.deep.equal({})

      it 'should habe a @pathToLocale', ->
        expect(i18n.pathToLocale).to.be.a('string')

      it 'should have a @init method', ->
        expect(i18n.init).to.be.a('function')

      it 'should have a @setDefault method', ->
        expect(i18n.setDefault).to.be.a('function')

      it 'should have a @t method', ->
        expect(i18n.t).to.be.a('function')

      it 'should have a @translate method', ->
        expect(i18n.translate).to.be.a('function')

    beforeEach ->
      window.__locale = undefined
      @i18n = null
      i18n.localization = {}
      @i18n = i18n
      @i18n.pathToLocale = '../../test-build/fixtures'

    describe '@init', ->

      it 'should set @__locale to @defaultLocale if window.__locale is undefined', ->
        expect(window.__locale).to.be.undefined
        @i18n.init()
        expect(@i18n.__locale).to.equal(@i18n.defaultLocale)

      it 'should get window.__locale in first instance', ->
        window.__locale = 'de'
        @i18n.init()
        @i18n.__locale.should.equal('de')

      it 'should load a json file when __locale is not @defaultLocale', ->
        window.__locale = 'de'
        spy = sinon.spy(@i18n, 'setLocalization')
        @i18n.init()

        expect(@i18n.localization).not.to.be.empty
        @i18n.localization.should.be.an('object')
        expect(@i18n.localization[window.__locale]).to.exist
        expect(spy.calledOnce).to.be.true
        @i18n.setLocalization.restore()

    describe '@setLocalization', ->
      it 'should set @localization', ->
        @i18n.setLocalization de_json_fixture

        @i18n.localization.should.not.be.empty
        @i18n.localization.should.deep.equal(JSON.parse(de_json_fixture))

    describe '@setDefault', ->
      it 'should set @defaultLocale and @__locale', ->
        expect(@i18n.defaultLocale).to.equal('en')

        @i18n.setDefault 'pl'
        @i18n.defaultLocale.should.equal('pl')
        @i18n.__locale.should.equal('pl')

    describe '@translate', ->

      it 'should find the right translation for a given key when window.__locale != @defaultLocale', ->
        window.__locale = 'de'
        @i18n.init()
        @i18n.setLocalization de_json_fixture

        translation = @i18n.translate "Hello World"
        expect(translation).to.equal("Hallo Welt")

      it 'should return the input string when window.__locale == @defaultLocale', ->
        spy = sinon.spy(@i18n, 'setLocalization')
        @i18n.init()

        expect(spy.called).to.be.false
        expect(@i18n.localization).to.deep.equal({})

        translation = @i18n.translate "Hello World"
        expect(translation).to.equal("Hello World")
        @i18n.setLocalization.restore()

      it 'should return a (?) prepended to the string argument when the language key is not available', ->
        window.__locale = 'de'
        @i18n.init()

        translation = @i18n.translate "Hello Mars"
        expect(translation).to.equal("(?) Hello Mars")

    describe '@t', ->
      it 'should call the @translate method on the argument', ->
        spy = sinon.spy(i18n, 'translate')
        @i18n.init()
        translation = @i18n.t "Hello World"
        expect(spy.calledOnce).to.be.true

      it 'should translate a normal string correctly', ->
        @i18n.init()
        translation = @i18n.t "Hello World"
        expect(translation).to.equal("Hello World")

      it 'should format a result with variables correctly', ->
        spy = sinon.spy(String.prototype, "fillWith")
        @i18n.init()
        translation = @i18n.t "My name is {0}, I am {1} years old and I love Chaplin.", "Pat", "26"
        
        expect(spy.called).to.be.true
        expect(translation).to.equal("My name is Pat, I am 26 years old and I love Chaplin.")
