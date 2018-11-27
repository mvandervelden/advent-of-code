
# Running:
# $ ruby example.rb [inputfilename]
# If no argument provided, it takes "input.txt"

class Solver
    def solve(filename = "input.txt")
        input = readfile(filename)
        # TODO solve
        input
    end

    def readfile(filename)
        File.read(filename)
    end
end

solver = Solver.new()
filename = ARGV[0]
if filename
    result = solver.solve(filename)
else
    result = solver.solve()
end

puts result
