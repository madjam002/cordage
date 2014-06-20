program = require 'commander'

program
.version '0.0.1'

commands = [
  require './deploy'
  require './list'
]

for Command in commands
  new Command program

program
.parse process.argv


# display help if no command/arguments provided
program.help() if program.args.length is 0
