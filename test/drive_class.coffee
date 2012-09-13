chai = require 'chai'
chai.Assertion.includeStack = true
chai.should()
expect = chai.expect
sinon = require('sinon')

Axle = require('../lib/axle.js')(global)
DriveClass = Axle.DriveClass

describe "DriveClass", ->
  it 'acts like a normal class', ->
    Foo = DriveClass()
    foo = new Foo()

    foo.should.be.a.instanceof Foo

  it "is evented", ->
    Foo = DriveClass()
    foo = new Foo()
    activated = null
    foo.on 'active', ->
      activated = true
    foo.trigger 'active'
    expect(activated).to.be.true

  describe "initialization", ->
    describe "optionize", ->
      it "sets instance variable for each key passed in", ->
        Foo = DriveClass()
        foo = new Foo {
          that: 'that',
          bar: 'baz',
          zardoz: {
            one: 1
          }
        }

        expect(foo.that).to.equal('that')
        expect(foo.bar).to.equal('baz')
        expect(foo.zardoz).to.deep.equal({one: 1})

      it "will set properties to their underscored property name", ->
        Foo = DriveClass {} , {
          properties: ['gear']
        }

        foo = new Foo { gear: 'first' }
        expect(foo._gear).to.equal('first')
        expect(foo.gear()).to.equal('first')

    it "calls init", ->
      inited = null
      Foo = DriveClass {
        init: ->
          inited = true
          @isNew = true
      }

      foo = new Foo()
      expect(inited).to.be.true
      expect(foo.isNew).to.be.true

    it "calls listen", ->
      listenedTo = null
      Foo = DriveClass {
        listen: ->
          listenedTo = true
          @listening = true
      }

      foo = new Foo()
      expect(listenedTo).to.be.true
      expect(foo.listening).to.be.true

    it "gets a unique incrementing id, within the axle space", ->
      Foo = DriveClass()
      foo = new Foo()
      expect(foo.uid).not.to.be.undefined
      id = foo.uid
      foo2 = new Foo()
      expect(foo2.uid).to.equal(id + 1)

  describe "#build", ->
    it "acts like new without all the forget-me-not drama", ->
      Foo = DriveClass({
        init: ->
          @inited = true
        ,
        listen: ->
          @listening = true
      })
      foo = Foo.build {
        accessing: true
      }

      expect(foo.listening).to.be.true
      expect(foo.inited).to.be.true
      expect(foo.accessing).to.be.true

  describe "publish/subscribe", ->
    it "it maitains a consistent publisher for all on the class level descendants", ->
      Foo = DriveClass()
      publisher = Foo.publisher()
      expect(Foo.publisher()).to.equal(publisher)

      Bar = DriveClass()
      expect(Bar.publisher()).to.equal(publisher)

    it "class level publisher can be set", ->
      Foo = DriveClass()
      foo = Foo.build()
      Foo.publisher(foo)
      expect(Foo.publisher()).to.equal(foo)

    describe "#subscribe", ->
      it "binds the provided callback to the event name of the publisher", ->
        Foo = DriveClass()
        foo = Foo.build()

        callback = sinon.spy()
        foo.subscribe('bar', callback)
        Foo.publisher().trigger('bar')
        expect(callback.calledOnce).to.be.true

      it "binds the callback to the subscribing object", ->
        Foo = DriveClass {
          driveBind: ->
            @driveBy = true
        }

        foo = Foo.build()
        foo.subscribe('drivingBy', foo.driveBind)
        Foo.publisher().trigger('drivingBy')
        expect(foo.driveBy).to.be.true

      it "will bind the callback to an alternative object", ->
        Foo = DriveClass {
          driveBind: ->
            @driveBy = true
        }

        foo = Foo.build()
        foo2 = Foo.build()

        foo.subscribe('drivingBy', foo2.driveBind, foo2)
        Foo.publisher().trigger('drivingBy')
        expect(foo.driveBy).to.be.undefined
        expect(foo2.driveBy).to.be.true

    describe "#publish", ->
      it "calls all the subscriptions", ->
        Foo = DriveClass()
        foo = Foo.build()
        foo.subscribe 'bar', ->
          @bar = true
        foo.subscribe 'bar', ->
          @baz = true

        foo.publish('bar')

        expect(foo.bar).to.be.true
        expect(foo.baz).to.be.true

      it "passes along the data to each callback", ->
        Foo = DriveClass()
        foo = Foo.build()
        foo.subscribe 'bar', (data) ->
          @bar = data
        foo.subscribe 'bar', (data) ->
          @baz = data

        foo.publish('bar', {called: true})

        expect(foo.bar).to.deep.equal({called: true})
        expect(foo.baz).to.deep.equal({called: true})

