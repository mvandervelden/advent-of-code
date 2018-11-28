
# Running:
# $ coffee example.coffee


config = 'input.txt'

foo = ->
  fs.readFileSync config, 'utf8'

class Solver
    solve: (filename) ->
        this.readFile filename

    readFile: (filename) ->
        fs = require 'fs'
        fs.readFileSync filename, 'utf8'

solver = new Solver
result = solver.solve "input.txt"

console.log result