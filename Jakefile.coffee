exec = require('child_process').exec

desc 'Run all the specs with mocha'
task 'mocha', ->
  exec 'mocha --compilers coffee:coffee-script --reporter list', (error, text) ->
    if error
      console.log( 'ERROR: ', error )
    else
      console.log( text )

