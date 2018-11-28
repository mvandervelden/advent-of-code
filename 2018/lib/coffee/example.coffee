
# Running:
# $ coffee example.coffee

config = 'input.txt'

class Solver
    solve: (filename) ->
        input = this.readFile filename
        #TODO solve
        input

    readFile: (filename) ->
        fs = require 'fs'
        fs.readFileSync filename, 'utf8'

solver = new Solver

if process.argv.length > 2
    result = solver.solve process.argv[2]
else
    result = solver.solve "input.txt"


console.log result