chalk = require 'chalk'
s = require 'string'

module.exports =
  info: (category, message = null) ->
    if message?
      console.log "#{chalk.bold.blue(s(category).padLeft(9))} #{chalk.bold.gray(':')}", message
    else
      console.log '   ', category

  action: (message, messages...) ->
    console.log chalk.bold('==>'), chalk.bold(message), messages...
