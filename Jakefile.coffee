exec = require('child_process').exec

desc 'Run all the specs with mocha'
task 'spec', ->
  exec 'mocha --compilers coffee:coffee-script --reporter list', (error, text) ->
    console.log( text )

