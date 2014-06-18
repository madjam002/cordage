program = require 'commander'

program
.version '0.0.1'

program
.command 'deploy <environment>'
.description 'builds and deploys your application'
.action (environment) ->
  require('./deploy').run environment

program
.parse process.argv


# display help if no command/arguments provided
program.help() if program.args.length is 0
