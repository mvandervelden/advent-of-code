
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

enum Orientation {
    case n, e, s, w

    func turn(_ direction: Int) -> Orientation {
        //infected == 1 == right
        //clean    == 0 == left
        switch (self, direction) {
        case (.n, 1), (.s, 0):
            return .e
        case (.n, 0), (.s, 1):
            return .w
        case (.e, 1), (.w, 0):
            return .s
        case (.e, 0), (.w, 1):
            return .n
        default:
            fatalError("invalid direction: \(direction)")
        }
    }
}

class Grid {
    var grid: [[Int]]
    var position: (x: Int, y: Int) = (0, 0)
    var orientation: Orientation = .n
    var offset: Int {
        return grid.count / 2
    }
    var infected = 0

    init(string: String) {
        let lines = string.split(separator: "\n")
        grid = lines.map { line in
            line.map { character in 
                switch character {
                case "#":
                    return 1
                default:
                    return 0
                }
            }
        }
    }

    subscript(x: Int, y: Int) -> Int {
        get {
            if offset - y >= grid.count || x + offset >= grid.count || offset - y < 0 || x + offset < 0 {
                return 0
            }
            return grid[offset - y][x + offset]
        }
        set {
            if x + offset >= grid.count || offset - y >= grid[0].count
                || x + offset < 0 || offset - y < 0 {
                let newGrid = gridOfSize(grid.count + 4)
                fill(newGrid, offset: 2)
            }
            grid[offset - y][x + offset] = newValue
        }
    }

    func step() {
        let value = self[position.x, position.y]
        orientation = orientation.turn(value)
        let newValue = (value + 1) % 2
        self[position.x, position.y] = newValue
        if newValue == 1 {
            infected += 1
        }

        move()
    }

    func move() {
        switch orientation {
        case .n:
            position = (position.x, position.y + 1)
        case .s:
            position = (position.x, position.y - 1)
        case .w:
            position = (position.x - 1, position.y)
        case .e:
            position = (position.x + 1, position.y)
        }
    }

    func gridOfSize(_ size: Int) -> [[Int]] {
        return Array(repeatElement(Array(repeatElement(0, count: size)), count: size))
    }

    func fill(_ newGrid: [[Int]], offset: Int) {
        var newGrid = newGrid
        grid.enumerated().forEach { column in
            column.element.enumerated().forEach { item in
                newGrid[column.offset + offset][item.offset + offset] = item.element
            }
        }
        grid = newGrid
    }
}

extension Grid: CustomDebugStringConvertible {
    var debugDescription: String {
        return grid.enumerated().reduce("") { (linesString, line) in
            return linesString + "\n" + line.element.enumerated().reduce("") { (itemsString, item) in
                if offset - position.y == line.offset && position.x + offset == item.offset {
                    return itemsString + "[\(item.element)]"
                }
                return itemsString + " \(item.element) "
            }
        }
    }
}

func solve1(fileName: String = "input.txt") {
    let input = readTerminal(fileName)
    let grid = Grid(string: input)

    for _ in 0..<10_000 {
        grid.step()
        // print(grid)
        // print(grid.infected)
    }
    
    print(grid)
    print(grid.infected)
}


if CommandLine.arguments.count > 1 {
    let fileName = CommandLine.arguments[1]
    solve1(fileName: fileName)
} else {
    solve1()
}
