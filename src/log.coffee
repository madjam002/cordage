chalk = require 'chalk'
s = require 'string'

module.exports =
  # Public: Output information to the log
  info: (category, message = null) ->
    if message?
      console.log "#{chalk.bold.blue(s(category).padLeft(9))} #{chalk.bold.gray(':')}", message
    else
      console.log '   ', category

  # Public: Output an action in progress to the log
  action: (message, messages...) ->
    console.log chalk.bold('==>'), chalk.bold(message), messages...

  # Public: Output an error to the log
  error: (title, message) ->
    console.log chalk.bold.red('==>'), chalk.bold.red(title)
    console.log '   ', chalk.red(message)
