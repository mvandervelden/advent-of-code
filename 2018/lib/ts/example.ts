import fs = require('fs');

// Running:
// $ tsc example.ts
// $ node example.js

class Solver {
    public solve(filename: string): string {
        let input = this.readFile(filename)
        // TODO solve
        return input;
    } 

    private readFile(filename: string): string {
        return fs.readFileSync(filename,'utf8');
    }
}

let solver = new Solver();
let result: string

if (process.argv.length > 2) {
    result = solver.solve(process.argv[2]);
} else {
    result = solver.solve("input.txt");
}

console.log(result);
