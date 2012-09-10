module.exports = function(root) {
  return (function(polluter) {
    var EventedClass = require('./evented_class')(polluter);
    var DriveClass = EventedClass({
      initialize: function(opts) {
        this.preInit(opts);
        this.init(opts);
        this.postInit(opts);
      },

      preInit: function(opts) {
        this.uid = this._class.uid();
        this.optionize(opts);
      },

      optionize: function(opts) {
        for (var opt in opts) {
          if ( typeof this._class.prototype[opt] == 'function' ) {
            // is a property
            this['_'+opt] = opts[opt];
          } else {
            this[opt] = opts[opt];
          }
        }
      },

      init: function(opts) {
        // override
      },

      postInit: function(opts) {
        this.listen();
      },

      listen: function() {
        // override
      },

      subscribe: function(event, callback, context) {
        this._class.publisher().on(event, callback, context||this);
      },

      publish: function(event, data) {
        this._class.publisher().trigger(event, data);
      }
    }, {
      uid: function() {
        this._uid || (this._uid = 0);
        return ++ this._uid;
      },

      build: function() {
        var klass = this;

        function Class(args) {
          return klass.apply(this, args);
        }
        Class.prototype = klass.prototype;

        return new Class(arguments);
      },

      publisher: function(obj) {
        if (obj) { this._publisher = obj; }
        if (!this._publisher) {
          this._publisher = DriveClass._publisher = DriveClass.build();
        }
        return this._publisher
      }
    });

    return function(x,y,z) {
      return DriveClass.subclass(x,y,z);
    }
  })(root);
};
