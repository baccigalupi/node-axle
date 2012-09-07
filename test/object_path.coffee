chai = require 'chai'
chai.Assertion.includeStack = true
chai.should()
expect = chai.expect

ObjectPath = require('../lib/object_path.js')(global)

describe 'ObjectPath', ->
  describe '#write', ->
    describe "polluting to the global space", ->
      it 'builds the full path with object literals, if none are found in global', ->
        ObjectPath.write('Foo.Bar.Zardoz', 3)
        expect(global.Foo).to.deep.equal({Bar: {Zardoz: 3}})

      it 'does not overwrite existing objects', ->
        func = ->
          # nothing doing here
        global.Bar = func
        ObjectPath.write('Bar.Foo.Zardoz', 42)
        expect(global.Bar).to.equal(func)
        expect(global.Bar.Foo).to.deep.equal({Zardoz: 42})

      it 'works when the path is not an object path', ->
        ObjectPath.write('Wazup', 42)
        expect(global.Wazup).to.equal(42)

      it 'return the full path', ->
        expect(ObjectPath.write('Kiss.My.App', 13)).to.equal(Kiss.My.App)

    describe "decorating a passed in object", ->
      Gotta = {}
      ObjectPath.write('Have', 'that funk', Gotta)
      expect(Gotta.Have).to.equal('that funk')


  describe '#read', ->
    it 'will get the value at a path on the global space', ->
      ObjectPath.write('Kiss.My.App', 13)
      expect(ObjectPath.read('Kiss.My.App')).to.equal(13)

    it 'will return null if the path does not exist on the global', ->
      expect(ObjectPath.read('Funk.The.Dunk')).to.equal(null)

    it "will read from a passed in base object", ->
      Kill = {
        My: {
          Landlord: 'the coop'
        }
      }
      expect(ObjectPath.read('My.Landlord', Kill)).to.equal('the coop')




