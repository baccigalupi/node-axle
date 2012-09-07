module.exports = function(root) {
  global.root = root;
  return function(x, y, z) {
    return EventedClass.subclass(x, y, z);
  };
};

var Class = require('./class.js')(global.root);
var EventEmitter = require('events').EventEmitter;
var EventedClass = Class();

EventedClass.mixin(EventEmitter.prototype);

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
