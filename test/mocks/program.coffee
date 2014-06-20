program = jasmine.createSpyObj 'program', ['command', 'description', 'action']
program.command.andReturn program
program.description.andReturn program
program.action.andReturn program

module.exports = program
