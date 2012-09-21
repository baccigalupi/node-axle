Axel
====

Axel is a series of pseudo-classical inheritance classes and pattern
extracted from the front-end framework
[Wheel.js](http://github.com/baccigalupi/wheel.js) and ported to node.js. 
The class structure is inspired by Ruby, with inheritance of both class 
and instance methods, with the ability to call back to the super method. 
In addition, and to keep your code dry and flexible, mixins are available
on the class and instance level too.

Axel provides three classes:
* Class: Just your basic no frills class with inheritance and mixins!
* EventedClass: A Class that also descends from EventEmitter, plus it
  has evented properties
* DriveClass: An EventedClass with some excellent extras. You will just
  have to read that section to know more about it

Class
-----
 
EventedClass
------------

DriveClass
----------
