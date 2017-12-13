
// to run: `swift code.swift [input_filename]`
import Foundation

func readTerminal(_ fileName: String) -> String {
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    guard let fileURL = URL(string: fileName, relativeTo: currentDirectoryURL) else {
        print("file not found: \(currentDirectoryURL.path)/\(fileName)")
        return ""
    }
    let content = try! String(contentsOf: fileURL)
    return content
}

struct Cube {
    let x: Int
    let y: Int
    let z: Int

    func next(string: String) -> Cube {
        switch string {
        case "n":
            return Cube(x: x + 1, y: y, z: z - 1)
        case "ne":
            return Cube(x: x + 1, y: y - 1, z: z)
        case "se":
            return Cube(x: x, y: y - 1, z: z + 1)
        case "s":
            return Cube(x: x - 1, y: y, z: z + 1)
        case "sw":
            return Cube(x: x - 1, y: y + 1, z: z)
        case "nw":
            return Cube(x: x, y: y + 1, z: z - 1)
        default:
            fatalError()
        }
    }

    func distance(from: Cube) -> Int {
        let diffX: Int = abs(x - from.x)
        let diffY: Int = abs(y - from.y)
        let diffZ: Int = abs(z - from.z)
        // let add1 = (diffX + diffY + diffZ) % 2
        return ((diffX + diffY + diffZ)/2) //+ add1
    }

    static var zero: Cube {
        return Cube(x: 0, y: 0, z: 0)
    }
}

extension Cube: CustomStringConvertible {
    var description: String {
        return "(\(x), \(y), \(z))"
    }
}

func solve1(fileName: String = "input.txt") {
    let input = readTerminal(fileName)
    let directions = input.split(separator: ",")
    var maxDist = 0
    var cube = Cube.zero
    for next in directions {
        cube = cube.next(string: String(next))
        maxDist = max(cube.distance(from: Cube.zero), maxDist)
        // print(cube)
        // print(cube.distance(from: Cube.zero))
    }

    print(cube)
    print(cube.distance(from: Cube.zero))
    print(maxDist)
}

if CommandLine.arguments.count > 1 {
    let fileName = CommandLine.arguments[1]
    solve1(fileName: fileName)
} else {
    solve1()
}
