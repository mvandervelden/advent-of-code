import Foundation

// Running:
// $ swift solver.swift [inputfilename]
// If no argument provided, it takes "input.txt"

extension String {
    static let none = "."
}

class Solver {

    func distance(coordinate: (id: String, x: Int, y: Int), matrixPoint: (label: String, x: Int, y: Int)) -> Int {
        return abs(coordinate.x - matrixPoint.x) + abs(coordinate.y - matrixPoint.y)
    }

    func solve(_ fileName: String = "input.txt") -> String {
        let input = readFile(fileName)
        let result1 = solve1(input: input)
        let result2 = solve2(input: input)
        return "r1: \(result1)\nr2: \(result2)"
    }

    private func solve1(input: String) -> String {
        let coordinates: [(id: String, x: Int, y: Int)] = input.split(separator: "\n").map { $0.split(separator: ",") }.enumerated().map { (id: String($0.offset), x: Int($0.element[0])!, y: Int($0.element[1].dropFirst())!) }
        let bounds = (minx: coordinates.min { $0.x < $1.x }!.x, miny: coordinates.min { $0.y < $1.y }!.y, maxx: coordinates.max { $0.x < $1.x }!.x, maxy: coordinates.max { $0.y < $1.y }!.y)
        // print(bounds)
        // print(coordinates)

        var matrix: [[(label: String, x: Int, y: Int)]] = (bounds.minx...bounds.maxx).map { x in
            return (bounds.miny...bounds.maxy).map { y in 
                return (label: .none, x: x, y: y)
            }
        }

        // print(matrix.count)
        // print(matrix[0].count)

        for row in matrix.enumerated() {
            for col in row.element.enumerated() {
                let distances = coordinates.map { distance(coordinate: $0, matrixPoint: col.element) }
                let minDist = distances.min()
                let minDistIndexes = distances.enumerated().filter { $0.element == minDist }.map { $0.offset }
                if minDistIndexes.count == 1 {
                    let id = coordinates[minDistIndexes[0]].id
                    matrix[row.offset][col.offset] = (label: id, x: col.element.x, y: col.element.y)
                }
            }
        }

        var boundIDs: Set<String> = []
        boundIDs.formUnion(Set(matrix.first!.map { $0.label }))
        boundIDs.formUnion(Set(matrix.last!.map { $0.label }))
        let firstLastCols: [String] = matrix.flatMap { (row: [(label: String, x: Int, y: Int)]) in 
        [row.first!.label, row.last!.label] }
        boundIDs.formUnion(Set(firstLastCols))

        let nonInfinites = coordinates.map { $0.id }.filter { id in
            !boundIDs.contains(id)
        }

        let areas: [Int] = nonInfinites.map { (id: String) in
            return matrix.reduce(0) { (sum: Int, row: [(label: String, x: Int, y: Int)]) in
                return sum + row.reduce(0) { (sum: Int, item: (label: String, x: Int, y: Int)) in
                    return sum + (item.label == id ? 1 : 0)
                }
            }
        }  

        return "\(areas.max()!)"
    }

    private func solve2(input: String) -> String {
       let matrix = self.matrix(fromInput: input)

        var regionSize = 0

        for row in matrix {
            for col in row {
                let totalDistance = coordinates.map { distance(coordinate: $0, matrixPoint: col) }.reduce(0, +)

                if totalDistance < (input == "example.txt" ? 32 : 10_000) {
                    regionSize += 1
                }
            }
        }

        return "\(regionSize)"
    }

    func matrix(fromInput input: String) -> [[(label: String, x: Int, y: Int)]] {
        let coordinates: [(id: String, x: Int, y: Int)] = input.split(separator: "\n").map { $0.split(separator: ",") }.enumerated().map { (id: String($0.offset), x: Int($0.element[0])!, y: Int($0.element[1].dropFirst())!) }
        let bounds = (minx: coordinates.min { $0.x < $1.x }!.x, miny: coordinates.min { $0.y < $1.y }!.y, maxx: coordinates.max { $0.x < $1.x }!.x, maxy: coordinates.max { $0.y < $1.y }!.y)

        let matrix: [[(label: String, x: Int, y: Int)]] = (bounds.minx...bounds.maxx).map { x in
            return (bounds.miny...bounds.maxy).map { y in 
                return (label: .none, x: x, y: y)
            }
        }
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