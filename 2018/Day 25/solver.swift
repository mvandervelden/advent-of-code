import Foundation

// Running:
// $ swift solver.swift [inputfilename]
// If no argument provided, it takes "input.txt"

class Solver {

    func solve(_ fileName: String = "input.txt") -> String {
        let input = readFile(fileName)
        let result1 = solve1(input: input)
        let result2 = solve2(input: input)
        return "r1: \(result1)\nr2: \(result2)"
    }

    typealias Point = [Int]

    private func solve1(input: String) -> String {
        let points: [Point] = input.split(separator: "\n").map { $0.split(separator: ",").map { Int($0)! } }
        print(points)

        var constellations: [[Point]] = []
        for pt in points {
            print(pt)
            var matchingConstellations: Set<Int> = []
            for constellation in constellations.enumerated() {
                for cpt in constellation.element {
                    if dist(p1: pt, p2: cpt) <= 3 {
                        matchingConstellations.insert(constellation.offset)
                    }
                }
            }

            switch matchingConstellations.count {
            case 0:
                print("new const")
                constellations.append([pt])
            case 1:
                print("appending to", matchingConstellations.first!)
                constellations[matchingConstellations.first!].append(pt)
            default:
                print("mergin consts")
                var newConstellation: [Point] = [pt]
                print(matchingConstellations)
                for i in matchingConstellations.sorted().reversed() {
                    // print(i)
                    print(constellations[i])
                    newConstellation.append(contentsOf: constellations[i])
                    constellations.remove(at: i)
                }

                print("merged const", newConstellation)
                constellations.append(newConstellation)
            }
        }

        constellations.forEach {
            print($0)
        }
        return "\(constellations.count)"
    }

    private func solve2(input: String) -> String {
        // let lines = input.split(separator: "\n")

        return ""
    }

    func dist(p1: Point, p2: Point) -> Int {
        let d1: Int = abs(p1[0] - p2[0])
        let d2: Int = abs(p1[1] - p2[1])
        let d3: Int = abs(p1[2] - p2[2])
        let d4: Int = abs(p1[3] - p2[3])

        return d1 + d2 + d3 + d4
    }

    private func readFile(_ fileName: String) -> String {
        let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        guard let fileURL = URL(string: fileName, relativeTo: currentDirectoryURL) else {
            print("file not found: \(currentDirectoryURL.path)/\(fileName)")
            return ""
        }
        let content = try! String(contentsOf: fileURL)
        return content
    }
}

let solver = Solver()
let result: String

if CommandLine.arguments.count > 1 {
    result = solver.solve(CommandLine.arguments[1])
} else {
    result = solver.solve()
}

print(result)