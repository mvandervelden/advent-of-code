
// Running:
// $ node example.js [inputfilename]

class Solver {
    constructor() {
        this.solve = function (filename) {
            var input = this.readFile(filename);
            //TODO solve
            return input;
        };

        this.readFile = function (filename) {
            var fs = require('fs');
            return fs.readFileSync(filename, 'utf8');
        };
    }
}

var solver = new Solver();

if (process.argv.length > 2) {
    var result = solver.solve(process.argv[2])
} else {
    var result = solver.solve("input.txt")
}

console.log(result);