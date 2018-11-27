#!/usr/bin/python

import sys

# Running:
# $ python example.py [inputfilename]
# If no argument provided, it takes "input.txt"

class Solver:
    def solve(self, filename):
        input = self.readFile(filename)
        # TODO solve
        return input

    def readFile(self, filename):
        file = open(filename, "r")
        return file.read()

solver = Solver()

if len(sys.argv) > 1:
    result = solver.solve(sys.argv[1])
else:
    result = solver.solve("input.txt")

print(result)