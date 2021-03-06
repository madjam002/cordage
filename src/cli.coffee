program = require 'commander'
config = require './config'

program
.version '0.0.1'

commands = [
  require './deploy'
  require './destroy'
  require './list'
]

for Command in commands
  new Command program, config

program
.parse process.argv


# display help if no command/arguments provided
program.help() if program.args.length is 0
