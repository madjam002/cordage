program = jasmine.createSpyObj 'program', ['command', 'description', 'action', 'option']
program.command.andReturn program
program.description.andReturn program
program.action.andReturn program
program.option.andReturn program

module.exports = program
