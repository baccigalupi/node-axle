/* taken from Ember.js! */
var wrap = function(func, superFunc) {
  function K() {}

  var newFunc = function() {
    var returnValue;
    var sup = this._super;
    this._super = superFunc || K;
    this['super'] = this._super; // for easy coffee-scripting
    returnValue = func.apply(this, arguments);
    this._super = sup;
    this['super'] = this._super; // for easy coffee-scripting
    return returnValue;
  };

  newFunc.base = func;
  return newFunc;
};

var superExtend = function(base, props, mashing) {
  if (!props) { return base; }

  for(var prop in props) {
    // don't copy intrinsic properties
    if ( prop.match(/prototype|__proto__|_subclass/) ) { continue; }

    var bottom, top;
    if (mashing) {
      bottom = props[prop];
      top = base[prop];
    } else {
      bottom = base[prop];
      top = props[prop];
    }

    if ( bottom && top && (typeof top == 'function') ) {
      base[prop] = (function(func, _super){
        return wrap(func, _super);
      })(top, bottom);
    } else if (top || bottom) {
      base[prop] = top || bottom;
    }
  }
  return base;
};

module.exports = function(root) {
  return (function(polluter) {
    var ObjectPath = require('./object_path')(polluter);

    var Class = function() {};
    Class.mashin = function(props) {
      superExtend(this, props, true);
      return this;
    };

    Class.mashover = function(props) {
      superExtend(this, props);
      return this;
    };

    Class.mixin = function(props) {
      superExtend(this.prototype, props, true);
      return this;
    };

    Class.mixover = function(props) {
      superExtend(this.prototype, props);
      return this;
    };

    var initializing = false;
    Class._subclass = function(x, y, z) {
      initializing = true;
      var proto = new this();
      initializing = false;

      var id, iProps, cProps;
      if (typeof x == 'string') {
          id = x;
          iProps = y;
          cProps = z;
        } else {
          iProps = x;
          cProps = y;
        }

      // high level constructor
      function Class() {
        if (!initializing) {
          if (this.initialize) {
            this.initialize.apply(this, arguments);
          }
        }
      }

      // add existing class method from old class
      for( var prop in this ) {
        if ( prop.match(/^prototype$|^id$/) ) { continue; }
        Class[prop] = this[prop];
      }

      superExtend(Class, cProps);
      Class.superclass = this;
      Class.subclass = Class.subclass || Class._subclass;
      Class.prototype = superExtend(proto, iProps);
      Class.prototype.constructor = Class;
      Class.prototype.superclass = this.prototype;
      Class.prototype._class = Class.prototype.constructor; // more intuitive access ??
      Class.prototype['class'] = Class.prototype.constructor; // works easy in coffee-script

      if (id) {
        Class.id = id; // a little introspection
        if (polluter) {
          ObjectPath.write(id, Class);
        }
      }

      return Class;
    };

    return function(x, y, z) {
      return Class._subclass(x, y, z);
    };
  }(root));
};
