chai = require 'chai'
chai.Assertion.includeStack = true
chai.should()
expect = chai.expect

EventedClass = require('../lib/evented_class.js')(this)

describe 'EventedClass', ->
  it 'acts like a normal class', ->
    Foo = EventedClass {
      initialize: (opts)->
        @opts = opts
    }

    foo = new Foo {bar: 'bar', baz: 'baz'}

    foo.opts.should.deep.equal {bar: 'bar', baz: 'baz'}
    foo.should.be.a.instanceof Foo

  describe 'from EventEmitter', ->
    Foo = null
    foo = null
    Bar = null
    bar = null

    beforeEach ->
      Foo = EventedClass()
      foo = new Foo()
      Bar = EventedClass()
      bar = new Bar()

    it 'are preset', ->
      expect(foo.on).to.not.be.undefined
      expect(foo.once).to.not.be.undefined
      expect(foo.removeListener).to.not.be.undefined
      expect(foo.emit).to.not.be.undefined

    it 'are aliased', ->
      expect(foo.off).to.equal(foo.removeListener)
      expect(foo.trigger).to.equal(foo.emit)

    it '#once is modified to take an additional argument that is the context', ->
      foo.once('funk', ->
        @.funky = true
      , bar)

      foo.trigger('funk')
      expect(bar.funky).to.be.true

      bar.funky = 'fruity too'
      foo.emit('funk')
      expect(bar.funky).to.equal('fruity too')

    it '#on is modified to take an additional argument that is the context', ->
      foo.on('something', ->
        @.else = true
      , bar)

      foo.trigger 'something'
      expect(bar.else).to.be.true

    it "#off/#removeListener works with the additional argument", ->
      callback = ->
        @.not = 'definitely'

      foo.on 'maybe', callback, bar
      foo.off 'maybe', callback, bar

      foo.trigger 'maybe'
      expect(bar.not).to.be.undefined


  #describe "properties"
