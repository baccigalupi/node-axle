module.exports = function(root) {
  return (function(polluter) {
    var Class = require('./class.js')(polluter);
    var EventEmitter = require('events').EventEmitter;
    var EventedClass = Class(EventEmitter.prototype, {
      attrAccessor: function(prop) {
        var propId = '_'+prop;
        this.prototype[prop] = function(value){
          if (value !== undefined) {
            var oldValue = this[propId];
            this[propId] = value;
            if (oldValue !== value) {
              this.trigger('change');
              this.trigger('change:'+prop);
            }
          }
          return this[propId];
        };
      },

      subclass: function(name, iprops, cprops) {
        var klass = this._subclass(name, iprops, cprops);
        if (klass.properties && klass.properties.length) {
          klass.properties.forEach(function(prop) {
            if ( typeof klass.prototype[prop] !== 'function' ) {
              klass.attrAccessor(prop);
            }
          });
        }
        return klass;
      }
    });

    var contextualized = function(event, callback, context) {
      if (context) {
        var boundCallback = callback.bind(context);
        this._mapEvent(event, callback, context, boundCallback);
        callback = boundCallback;
      }
      this._super(event, callback);
    };

    EventedClass.mixover({
      _mapEvent: function(event, callback, context, boundCallback) {
        this._eventMap || (this._eventMap = {});
        this._eventMap[event] || (this._eventMap[event] = []);
        this._eventMap[event].push({
          callback: callback,
          boundCallback: boundCallback,
          context: context
        });
      },

      once: contextualized,

      on: contextualized,

      removeListener: function(event, callback, context) {
        if (context) {
          var maps = this._eventMap[event];
          maps && maps.forEach(function(map) {
            map.callback === callback && map.context === context && (callback = map.boundCallback);
          });
        }
        this._super(event, callback);
      }
    });

    EventedClass.prototype.off = EventedClass.prototype.removeListener;
    EventedClass.prototype.trigger = EventedClass.prototype.emit;

    return EventedClass;
  })(root);
};
