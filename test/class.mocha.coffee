chai = require 'chai'
chai.Assertion.includeStack = true
chai.should()
expect = chai.expect

Class = require('../lib/class.js')(this)

describe 'Class', ->
  methods = null
  beforeEach ->
    methods = {
      base: (value) ->
        template =  '`' + value + '`'
        return template
      ,
      child: (value) -> return "<div class='wrapper'>#{this._super(value)}</div>",
      grandchild: (value) -> return "<div class='jacket'>#{this._super(value)}</div>"
    }

  it 'creates a class that call initialize', ->
    Foo = Class {
      initialize: (opts)->
        @opts = opts
    }

    foo = new Foo {bar: 'bar', baz: 'baz'}

    foo.opts.should.deep.equal {bar: 'bar', baz: 'baz'}

  describe "inheritance", ->
    Repeater = null; Wrapper = null; Jacket = null
    repeater = null; wrapper = null; jacket = null

    describe "instance methods chain through the ancestors", ->
      beforeEach ->
        Repeater = Class {
          print: methods.base
        }

        Wrapper = Repeater.subclass {
          print: methods.child
        }

        Jacket = Wrapper.subclass {
          print: methods.grandchild
        }

        repeater = new Repeater()
        wrapper = new Wrapper()
        jacket = new Jacket()

      it "base class gets the right instance method when set up with Class()", ->
        expect( repeater.print('foo')).to.equal('`foo`')

      it "children can use _super in context to get superclasses method invocation", ->
        expect( wrapper.print('foo')).to.equal("<div class='wrapper'>`foo`</div>")

      it "grandchildren get a _super that goes all the way up the chain to the base class", ->
        expect( jacket.print('foo')).to.equal("<div class='jacket'><div class='wrapper'>`foo`</div></div>")

    describe "coffee-script special `super` sauce", ->
      beforeEach ->
        methods.child = (value) -> return "<div class='wrapper'>#{@.super(value)}</div>"
        methods.grandchild = (value) -> return "<div class='jacket'>#{@.super(value)}</div>"

        Repeater = Class {
          print: methods.base
        }

        Wrapper = Repeater.subclass {
          print: methods.child
        }

        Jacket = Wrapper.subclass {
          print: methods.grandchild
        }

        repeater = new Repeater()
        wrapper = new Wrapper()
        jacket = new Jacket()


      it "children can use super directly in context to get superclasses method invocation", ->
        expect( wrapper.print('foo')).to.equal("<div class='wrapper'>`foo`</div>")

      it "grandchildren get a super that goes all the way up the chain to the base class", ->
        expect( jacket.print('foo')).to.equal("<div class='jacket'><div class='wrapper'>`foo`</div></div>")

  describe "mix and mash extensions", ->
    Base = null; base = null

    describe "mixin ... instance level extension", ->
      it "adds new instance properties", ->
        Base = Class methods
        Base.mixin {
          newMethod: ->
            @foo = 'foo'
          ,
          newVar: 'shiny!'
        }

        base = new Base()

        base.newMethod()
        expect(base.foo).to.equal('foo')
        expect(base.newVar).to.equal('shiny!')

      it "instance methods will be layered underneath existing class methods", ->
        Base = Class {
          print: methods.child
        }
        Base.mixin {
          print: (value) ->
            return "<mixed>#{value}</mixed>"
        }

        base = new Base()
        expect(base.print('foo')).to.equal("<div class='wrapper'><mixed>foo</mixed></div>")

    describe "mixover ... instance level extension with clobbering", ->
      it "adds new instance properties", ->
        Base = Class methods
        Base.mixin {
          newMethod: ->
            @foo = 'foo'
          ,
          newVar: 'shiny!'
        }

        base = new Base()

        base.newMethod()
        expect(base.foo).to.equal('foo')
        expect(base.newVar).to.equal('shiny!')

      it "instance methods will be layered on top of existing methods", ->
        Base = Class {
          print: methods.base
        }
        Base.mixover {
          print: (value) ->
            return "<mixed>#{@super(value)}</mixed>"
        }

        base = new Base()
        expect(base.print('foo')).to.equal("<mixed>`foo`</mixed>")

    describe "mashin ... class level extension", ->
      it "adds new class properties", ->
        Base = Class {}, methods
        Base.mashin {
          newMethod: ->
            @foo = 'foo'
          ,
          newVar: 'shiny!'
        }

        Base.newMethod()
        expect(Base.foo).to.equal('foo')
        expect(Base.newVar).to.equal('shiny!')

      it "class methods will be layered underneath existing class methods", ->
        Base = Class {}, {
          print: methods.child
        }
        Base.mashin {
          print: (value) ->
            return "<mixed>#{value}</mixed>"
        }

        expect(Base.print('foo')).to.equal("<div class='wrapper'><mixed>foo</mixed></div>")

   describe "mashover ... class level extension, with clobber capabilities", ->
      it "adds new class properties", ->
        Base = Class {}, methods
        Base.mashover {
          newMethod: ->
            @foo = 'foo'
          ,
          newVar: 'shiny!'
        }

        Base.newMethod()
        expect(Base.foo).to.equal('foo')
        expect(Base.newVar).to.equal('shiny!')

      it "class methods will be layered on top of existing class methods", ->
        Base = Class {}, {
          print: methods.base
        }
        Base.mashover {
          print: (value) ->
            template =  "<mixed>#{@super(value)}</mixed>"
            return template
        }

        expect(Base.print('foo')).to.equal("<mixed>`foo`</mixed>")
