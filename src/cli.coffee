program = require 'commander'

program
.version '0.0.1'

program
.command 'deploy'
.description 'builds and deploys your application'
.action ->
  require('./deploy').run()

program
.command 'list'
.description 'view services in the cluster'
.action ->
  require('./list').run()

program
.parse process.argv


# display help if no command/arguments provided
program.help() if program.args.length is 0
