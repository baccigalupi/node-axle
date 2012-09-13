module.exports = function(root) {
  return (function(polluter) {
    return {
      Class:        require('./axle/class.js')(polluter),
      EventedClass: require('./axle/evented_class.js')(polluter),
      DriveClass:   require('./axle/drive_class.js')(polluter)
    }
  }(root));
};
