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

    let carsSigns: [Character] = ["^", ">", "v", "<"]
    let trackSigns: [Character] = ["-", "|", "/", "\\", "+"]

    enum Direction: CustomStringConvertible {
        case up, right, down, left

        init?(character: Character) {
            switch character {
                case "^": self = .up
                case ">": self = .right
                case "v": self = .down
                case "<": self = .left
                default: return nil
            }
        }

        var track: Character {
            switch self {
                case .up, .down: return "|"
                case .left, .right: return "-"
            }
        }

        var description: String {
            switch self {
            case .up: return "^"
            case .right: return ">"
            case .down: return "v"
            case .left: return "<"
            }
        }
    }

    enum Track {
        case horizontal, vertical, crossing, slash, backslash

        init(character: Character) {
            switch character {
                case "-": self = .horizontal
                case "|": self = .vertical
                case "+": self = .crossing
                case "/": self = .slash
                case "\\": self = .backslash
                default: fatalError("unknown track: \(character)")
            }
        }
    }

    enum CrossingBehavior: CustomStringConvertible {
        case left, straight, right

        var next: CrossingBehavior {
            switch self {
                case .left: return .straight
                case .straight: return .right
                case .right: return .left
            }
        }

        var description: String {
            switch self {
                case .left: return "⬅️"
                case .right: return "➡️"
                case .straight: return "⬆️"
            }
        }
    }

    class Car: CustomStringConvertible {
        var x: Int
        var y: Int
        var dir: Direction
        var nextCrossing: CrossingBehavior

        init(x: Int, y: Int, dir: Direction, nextCrossing: CrossingBehavior) {
            self.x = x
            self.y = y
            self.dir = dir
            self.nextCrossing = nextCrossing
        }

        func update(x: Int, y: Int, dir: Direction, nextCrossing: CrossingBehavior) {
            self.x = x
            self.y = y
            self.dir = dir
            self.nextCrossing = nextCrossing
        }

        var description: String {
            return "(\(x),\(y)) \(dir) \(nextCrossing)"
        }
    }

    private func solve1(input: String) -> String {
        let lines = input.split(separator: "\n")
        var map: [[Character]] = lines.map { Array($0) }
        // print(map.count, map[0].count)


        let size = (width: map[0].count, height: map.count)

        var carLocations: [Car] = []

        (0..<size.height).forEach { y in
            (0..<size.width).forEach { x in
                if let dir = Direction(character: map[y][x]) {
                    carLocations.append(Car(x: x, y: y, dir: dir, nextCrossing: .left))
                    map[y][x] = dir.track
                }
            }
        }

        var didCrash: (x: Int, y: Int)? = nil

        while didCrash == nil {
            carLocations.sort { lhs, rhs in
                lhs.y < rhs.y || (lhs.y == rhs.y && lhs.x < rhs.x)
            }
            for car in carLocations {
                let nextCoord: (x: Int, y: Int)
                switch car.dir {
                    case .up: nextCoord = (x: car.x, y: car.y - 1)
                    case .right: nextCoord = (x: car.x + 1, y: car.y)
                    case .down: nextCoord = (x: car.x, y: car.y + 1)
                    case .left: nextCoord = (x: car.x - 1, y: car.y)
                }

                if !carLocations.filter({ $0.x == nextCoord.x && $0.y == nextCoord.y }).isEmpty {
                    didCrash = nextCoord
                    break
                }

                switch (Track(character: map[nextCoord.y][nextCoord.x]), car.dir, car.nextCrossing) {
                    case (.horizontal, _, _), (.vertical, _, _): car.update(x: nextCoord.x, y: nextCoord.y, dir: car.dir, nextCrossing: car.nextCrossing)
                    case (.slash, .right, _):  car.update(x: nextCoord.x, y: nextCoord.y, dir: .up, nextCrossing: car.nextCrossing)
                    case (.backslash, .right, _):  car.update(x: nextCoord.x, y: nextCoord.y, dir: .down, nextCrossing: car.nextCrossing)
                    case (.slash, .left, _):  car.update(x: nextCoord.x, y: nextCoord.y, dir: .down, nextCrossing: car.nextCrossing)
                    case (.backslash, .left, _):  car.update(x: nextCoord.x, y: nextCoord.y, dir: .up, nextCrossing: car.nextCrossing)
                    case (.slash, .up, _):  car.update(x: nextCoord.x, y: nextCoord.y, dir: .right, nextCrossing: car.nextCrossing)
                    case (.backslash, .up, _):  car.update(x: nextCoord.x, y: nextCoord.y, dir: .left, nextCrossing: car.nextCrossing)
                    case (.slash, .down, _):  car.update(x: nextCoord.x, y: nextCoord.y, dir: .left, nextCrossing: car.nextCrossing)
                    case (.backslash, .down, _): car.update(x: nextCoord.x, y: nextCoord.y, dir: .right, nextCrossing: car.nextCrossing)
                    case (.crossing, _, .straight): car.update(x: nextCoord.x, y: nextCoord.y, dir: car.dir, nextCrossing: car.nextCrossing.next)
                    case (.crossing, .up, .left): car.update(x: nextCoord.x, y: nextCoord.y, dir: .left, nextCrossing: car.nextCrossing.next)
                    case (.crossing, .up, .right): car.update(x: nextCoord.x, y: nextCoord.y, dir: .right, nextCrossing: car.nextCrossing.next)
                    case (.crossing, .right, .left): car.update(x: nextCoord.x, y: nextCoord.y, dir: .up, nextCrossing: car.nextCrossing.next)
                    case (.crossing, .right, .right): car.update(x: nextCoord.x, y: nextCoord.y, dir: .down, nextCrossing: car.nextCrossing.next)
                    case (.crossing, .down, .left): car.update(x: nextCoord.x, y: nextCoord.y, dir: .right, nextCrossing: car.nextCrossing.next)
                    case (.crossing, .down, .right): car.update(x: nextCoord.x, y: nextCoord.y, dir: .left, nextCrossing: car.nextCrossing.next)
                    case (.crossing, .left, .left): car.update(x: nextCoord.x, y: nextCoord.y, dir: .down, nextCrossing: car.nextCrossing.next)
                    case (.crossing, .left, .right): car.update(x: nextCoord.x, y: nextCoord.y, dir: .up, nextCrossing: car.nextCrossing.next)
                }
            }
        }

        return "\(didCrash!.x),\(didCrash!.y)"
    }

    private func solve2(input: String) -> String {
        let lines = input.split(separator: "\n")
        var map: [[Character]] = lines.map { Array($0) }

        let size = (width: map[0].count, height: map.count)

        var carLocations: [Car] = []

        (0..<size.height).forEach { y in
            (0..<size.width).forEach { x in
                if let dir = Direction(character: map[y][x]) {
                    carLocations.append(Car(x: x, y: y, dir: dir, nextCrossing: .left))
                    map[y][x] = dir.track
                }
            }
        }

        while true {
            if carLocations.count <= 1 {
                break
            }
            carLocations.sort { lhs, rhs in
                lhs.y < rhs.y || (lhs.y == rhs.y && lhs.x < rhs.x)
            }

            var i = 0
            while i < carLocations.count {
                // print(carLocations.count)
                let car = carLocations[i]

                let nextCoord: (x: Int, y: Int)
                switch car.dir {
                    case .up: nextCoord = (x: car.x, y: car.y - 1)
                    case .right: nextCoord = (x: car.x + 1, y: car.y)
                    case .down: nextCoord = (x: car.x, y: car.y + 1)
                    case .left: nextCoord = (x: car.x - 1, y: car.y)
                }

                if let otherCar = carLocations.enumerated().filter({ $0.element.x == nextCoord.x && $0.element.y == nextCoord.y }).first {
                    let j = otherCar.offset
                    // print("collision:\(nextCoord): i: \(i), j: \(j)")
                    if j < i {
                        carLocations.remove(at: i)
                        carLocations.remove(at: j)
                        i -= 1
                    } else {
                        carLocations.remove(at: j)
                        carLocations.remove(at: i)
                    }

                    continue
                    // if carLocations.count == 1 {
                    //     break
                    // } else {
                    //     print("will continue")
                    //     continue
                    // }
                } else {
                    i += 1
                }

                switch (Track(character: map[nextCoord.y][nextCoord.x]), car.dir, car.nextCrossing) {
                    case (.horizontal, _, _), (.vertical, _, _): car.update(x: nextCoord.x, y: nextCoord.y, dir: car.dir, nextCrossing: car.nextCrossing)
                    case (.slash, .right, _):  car.update(x: nextCoord.x, y: nextCoord.y, dir: .up, nextCrossing: car.nextCrossing)
                    case (.backslash, .right, _):  car.update(x: nextCoord.x, y: nextCoord.y, dir: .down, nextCrossing: car.nextCrossing)
                    case (.slash, .left, _):  car.update(x: nextCoord.x, y: nextCoord.y, dir: .down, nextCrossing: car.nextCrossing)
                    case (.backslash, .left, _):  car.update(x: nextCoord.x, y: nextCoord.y, dir: .up, nextCrossing: car.nextCrossing)
                    case (.slash, .up, _):  car.update(x: nextCoord.x, y: nextCoord.y, dir: .right, nextCrossing: car.nextCrossing)
                    case (.backslash, .up, _):  car.update(x: nextCoord.x, y: nextCoord.y, dir: .left, nextCrossing: car.nextCrossing)
                    case (.slash, .down, _):  car.update(x: nextCoord.x, y: nextCoord.y, dir: .left, nextCrossing: car.nextCrossing)
                    case (.backslash, .down, _): car.update(x: nextCoord.x, y: nextCoord.y, dir: .right, nextCrossing: car.nextCrossing)
                    case (.crossing, _, .straight): car.update(x: nextCoord.x, y: nextCoord.y, dir: car.dir, nextCrossing: car.nextCrossing.next)
                    case (.crossing, .up, .left): car.update(x: nextCoord.x, y: nextCoord.y, dir: .left, nextCrossing: car.nextCrossing.next)
                    case (.crossing, .up, .right): car.update(x: nextCoord.x, y: nextCoord.y, dir: .right, nextCrossing: car.nextCrossing.next)
                    case (.crossing, .right, .left): car.update(x: nextCoord.x, y: nextCoord.y, dir: .up, nextCrossing: car.nextCrossing.next)
                    case (.crossing, .right, .right): car.update(x: nextCoord.x, y: nextCoord.y, dir: .down, nextCrossing: car.nextCrossing.next)
                    case (.crossing, .down, .left): car.update(x: nextCoord.x, y: nextCoord.y, dir: .right, nextCrossing: car.nextCrossing.next)
                    case (.crossing, .down, .right): car.update(x: nextCoord.x, y: nextCoord.y, dir: .left, nextCrossing: car.nextCrossing.next)
                    case (.crossing, .left, .left): car.update(x: nextCoord.x, y: nextCoord.y, dir: .down, nextCrossing: car.nextCrossing.next)
                    case (.crossing, .left, .right): car.update(x: nextCoord.x, y: nextCoord.y, dir: .up, nextCrossing: car.nextCrossing.next)
                }
            }
        }

        return "\(carLocations[0].x),\(carLocations[0].y)"
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