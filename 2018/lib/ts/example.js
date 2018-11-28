"use strict";
exports.__esModule = true;
var fs = require("fs");
// Running:
// $ tsc example.ts
// $ node example.js
var Solver = /** @class */ (function () {
    function Solver() {
    }
    Solver.prototype.solve = function (filename) {
        var input = this.readFile(filename);
        // TODO solve
        return input;
    };
    Solver.prototype.readFile = function (filename) {
        return fs.readFileSync(filename, 'utf8');
    };
    return Solver;
}());
var solver = new Solver();
var result;
if (process.argv.length > 2) {
    result = solver.solve(process.argv[2]);
}
else {
    result = solver.solve("input.txt");
}
console.log(result);
