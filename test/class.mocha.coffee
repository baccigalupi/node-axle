chai = require 'chai'
chai.Assertion.includeStack = true
chai.should()

Class = require '../lib/class.js'

describe 'Class', ->
  it 'allows subclassing', ->
    Foo = Class {
      initialize: (opts)->
        @opts = opts
    }

    foo = new Foo {bar: 'bar', baz: 'baz'}

    foo.opts.should.deep.equal {bar: 'bar', baz: 'baz'}
