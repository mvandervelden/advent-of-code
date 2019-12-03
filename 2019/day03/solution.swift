import Foundation

// Running:
// $ ./solution.swift part [inputfilename]
// part: either `1` or `2`
// If no inputfilename provided, it takes "input.txt"

typealias Lines = [String]
typealias Words = [Lines]

class Solution {
  enum Part: Int {
    case one = 1, two
  }

  let part: Part
  let file: File

  init(part: Part, filename: String) {
    self.part = part
    file = File(filename: filename)
  }

  func get() -> String {
    switch part {
    case .one: return solveOne(file: file)
    case .two: return solveTwo(file: file)
    }
  }

  private func solveOne(file: File) -> String {
    let path1 = file.words.first!.vectors
    let path2 = file.words.last!.vectors
    var grid = Grid()

    for vector in path1 {
      grid.addVector(vector)
    }

    for vector in path2 {
      grid.addVector(vector)
    }
    return "\(grid.description)"
  }

  private func solveTwo(file: File) -> String {
    return "input: \(file.filename)\ncontent:\n\(file.words)\nresult 2"
  }
}

struct Grid {
  var currentGrid: [Int: [Int: GridPoint]]
  var currentCoordinates: (x: Int, y: Int) = (x: 0, y: 0)

  init() {
    currentGrid = [:]
    currentGrid[0] = [:]
    currentGrid[0]![0] = GridPoint.origin
  }

  mutating func addVector(_ vector: Vector) {
    //swiftlint:disable identifier_name
    switch vector.direction {
    case .up:
      for dy in 1..<vector.distance {
        let oldPoint = currentGrid[currentCoordinates.x]![currentCoordinates.x - dy]
        switch oldPoint {
        case .none:
          currentGrid[currentCoordinates.x]![currentCoordinates.x - dy] = .vPath
        case .some(.hPath):
          currentGrid[currentCoordinates.x]![currentCoordinates.x - dy] = .cross
        default:
          fatalError("""
            unexpected value in grid.
            coord: (\(currentCoordinates.x), \(currentCoordinates.x - dy)):
            \(currentGrid[currentCoordinates.x]![currentCoordinates.x - dy]!),
            for vector: \(vector)
          """)
        }
      }
      currentGrid[currentCoordinates.x]![currentCoordinates.y - vector.distance] = .corner
      currentCoordinates = (x: currentCoordinates.x, y: currentCoordinates.y - vector.distance)
    case .down:
      for y in (currentCoordinates.y + 1)..<(currentCoordinates.y + vector.distance) {
        let oldPoint = currentGrid[currentCoordinates.x]![y]
        switch oldPoint {
        case .none:
          currentGrid[currentCoordinates.x]![y] = .vPath
        case .some(.hPath):
          currentGrid[currentCoordinates.x]![y] = .cross
        default:
          fatalError("unexpected value in grid. coord: (\(currentCoordinates.x), \(y)): \(currentGrid[currentCoordinates.x]![y]!), for vector: \(vector)")
        }
      }
      currentGrid[currentCoordinates.x]![currentCoordinates.y + vector.distance] = .corner
      currentCoordinates = (x: currentCoordinates.x, y: currentCoordinates.y + vector.distance)
    case .left:
      for dx in 1..<vector.distance {
        if currentGrid[currentCoordinates.x - dx] == nil { currentGrid[currentCoordinates.x - dx] = [:] }

        let oldPoint = currentGrid[currentCoordinates.x - dx]![currentCoordinates.y]
        switch oldPoint {
        case .none:
          currentGrid[currentCoordinates.x - dx]![currentCoordinates.y] = .hPath
        case .some(.vPath):
          currentGrid[currentCoordinates.x - dx]![currentCoordinates.y] = .cross
        default:
          fatalError("""
            unexpected value in grid.
            coord: (\(currentCoordinates.x - dx), \(currentCoordinates.y)):
            \(currentGrid[currentCoordinates.x - dx]![currentCoordinates.y]!),
            for vector: \(vector)
          """)
        }
      }
      if currentGrid[currentCoordinates.x + vector.distance] == nil {
        currentGrid[currentCoordinates.x + vector.distance] = [:]
      }

      currentGrid[currentCoordinates.x - vector.distance]![currentCoordinates.y] = .corner
      currentCoordinates = (x: currentCoordinates.x - vector.distance, y: currentCoordinates.y)
    case .right:
      for x in (currentCoordinates.x + 1)..<(currentCoordinates.x + vector.distance) {
        if currentGrid[x] == nil { currentGrid[x] = [:] }

        let oldPoint = currentGrid[x]![currentCoordinates.y]
        switch oldPoint {
        case .none:
          currentGrid[x]![currentCoordinates.y] = .hPath
        case .some(.vPath):
          currentGrid[x]![currentCoordinates.y] = .cross
        default:
          fatalError("unexpected value in grid. coord: (\(x), \(currentCoordinates.y)): \(currentGrid[x]![currentCoordinates.y]!), for vector: \(vector)")
        }
      }
      if currentGrid[currentCoordinates.x + vector.distance] == nil {
        currentGrid[currentCoordinates.x + vector.distance] = [:]
      }

      currentGrid[currentCoordinates.x + vector.distance]![currentCoordinates.y] = .corner
      currentCoordinates = (x: currentCoordinates.x + vector.distance, y: currentCoordinates.y)
    }
    //swiftlint:enable identifier_name
  }

  var description: String {
    return ""
  }
}

enum GridPoint: Character {
  case origin = "o"
  case hPath = "-"
  case vPath = "|"
  case corner = "+"
  case cross = "X"
}

enum Direction: Character {
  //swiftlint:disable:next identifier_name
  case up = "U"
  case down = "D"
  case left = "L"
  case right = "R"
}

struct Vector {
  let direction: Direction
  let distance: Int

  init(string: String) {
    print(string)
    direction = Direction(rawValue: string.first!)!
    let distanceString = string.dropFirst()
    distance = Int(distanceString)!
  }
}

extension Array where Element == String {
  var vectors: [Vector] {
    return map(Vector.init)
  }
}

class File {
  let filename: String

  lazy var string: String = {
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    guard let fileURL = URL(string: filename, relativeTo: currentDirectoryURL),
          let contents = try? String(contentsOf: fileURL) else {
      fatalError("file not found: \(currentDirectoryURL.path)/\(filename)")
    }

    return contents
  }()

  lazy var lines: Lines = {
    let strings = "abc"

    return string.split(separator: "\n").map(String.init)
  }()

  lazy var words: Words = {
    return lines.map { $0.split(separator: ",").map(String.init) }
  }()

  init(filename: String) {
    self.filename = filename
  }
}

let filename = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "input.txt"
let part: Solution.Part = Solution.Part(rawValue: CommandLine.arguments.count > 1 ? Int(CommandLine.arguments[1])! : 1)!
let solution = Solution(part: part, filename: filename)
let result = solution.get()

print(result)
