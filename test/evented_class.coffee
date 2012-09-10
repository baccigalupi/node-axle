chai = require 'chai'
chai.Assertion.includeStack = true
chai.should()
expect = chai.expect
sinon = require('sinon')

EventedClass = require('../lib/evented_class.js')(global)

describe 'EventedClass', ->
  it 'acts like a normal class', ->
    Foo = EventedClass.subclass {
      initialize: (opts)->
        @opts = opts
    }

    foo = new Foo {bar: 'bar', baz: 'baz'}

    foo.opts.should.deep.equal {bar: 'bar', baz: 'baz'}
    foo.should.be.a.instanceof Foo

  it "can pollute the global space", ->
    Zardozerator = EventedClass.subclass 'Bar.Baz.Zardoz'
    expect(global.Bar).to.not.be.undefined
    expect(global.Bar.Baz).to.not.be.undefined
    expect(global.Bar.Baz.Zardoz).to.equal(Zardozerator)

  it "can pollute the global space even after another instance of the evented class creator has been spawned", ->
    context = {}
    Eventer = require('../lib/evented_class.js')(context)
    Klass = Eventer 'MyKlass'
    expect(global.MyKlass).to.be.undefined
    expect(context.MyKlass).to.equal(Klass)

    AnotherClass = EventedClass.subclass "Zardy.Baztipher.Fooo"
    expect(global.Zardy).to.not.be.undefined
    expect(global.Zardy.Baztipher).to.not.be.undefined
    expect(global.Zardy.Baztipher.Fooo).to.equal(AnotherClass)

  describe 'from EventEmitter', ->
    Foo = null
    foo = null
    Bar = null
    bar = null

    beforeEach ->
      Foo = EventedClass.subclass()
      foo = new Foo()
      Bar = EventedClass.subclass()
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
      foo.emit 'funk'
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


  describe "evented attribute accessors", ->
    Task = null; task = null; owner = null; props = null
    beforeEach ->
      Task = EventedClass.subclass {}, {
        properties: ['name', 'due_at', 'state']
      }

      task = new Task()
      owner = {name: "Kane"}
      props = {
        name: 'Do some meta',
        state: 0,
        due_at: null
      }

      owner = {name: "Kane"}

      Task.attrAccessor('owner')

    it 'creates a prototype function with that name', ->
      expect(typeof Task.prototype.owner == 'function').to.equal(true)


    it 'created accessor reads the underscore prefaced property', ->
      task._owner = owner
      expect(task.owner()).to.equal(owner)

    describe 'when given an argument', ->
      it 'it writes to the underscore prefaced property', ->
        task.owner(owner)
        expect(task._owner).to.equal(owner)

      it 'returns the value', ->
        expect(task.owner(owner)).to.equal(owner)

      describe 'when value has changed', ->
        beforeEach ->
          sinon.spy(task, "trigger")
          task.owner(owner)

        it 'triggers events', ->
          expect(task.trigger.withArgs('change').calledOnce).to.be.true
          expect(task.trigger.withArgs('change:owner').calledOnce).to.be.true

      describe 'value is the same', ->
        it 'does not trigger any events', ->
          sinon.spy(task, "trigger")
          task.owner(task._owner)
          expect(task.trigger.called).to.be.false

    it 'can handle multiple declarations in the same class', ->
      Task.attrAccessor('tags')
      tags = ['neato', 'jazzy']
      task.tags(tags)
      task.owner(owner)
      expect(task.tags()).to.equal(tags)
      expect(task.owner()).to.equal(owner)

    describe 'properties', ->
      SpecialTask = null
      beforeEach ->
        SpecialTask = Task.subclass 'SpecialTask', {}, {
          properties: ['specialness_rating']
        }

      it 'accesors are built at subclass time for properties', ->
        expect(typeof Task.prototype.name).to.equal('function')
        expect(typeof Task.prototype.state).to.equal('function')
        expect(typeof Task.prototype.due_at).to.equal('function')

        expect(task.name('Kane')).to.equal('Kane')
        expect(task.name()).to.equal('Kane')

      it 'property accesors are inherited from the super class', ->
        expect(typeof SpecialTask.prototype.name).to.equal('function')
        expect(typeof SpecialTask.prototype.state).to.equal('function')
        expect(typeof SpecialTask.prototype.due_at).to.equal('function')

      it 'subclasses can add their own properties', ->
        expect(typeof SpecialTask.prototype.specialness_rating).to.equal('function')
