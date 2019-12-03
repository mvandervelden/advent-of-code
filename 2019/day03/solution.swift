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
      grid.addVector(vector, wire: 1)
    }

    grid.resetToOrigin()

    for vector in path2 {
      grid.addVector(vector, wire: 2)
    }
    return grid.nearestIntersectionDistance().description
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
    currentGrid[0]![0] = GridPoint(value: .origin, wire: 0)
  }

  //swiftlint:disable:next cyclomatic_complexity function_body_length
  mutating func addVector(_ vector: Vector, wire: Int) {
    // print(description)
    //swiftlint:disable identifier_name
    let x = currentCoordinates.x
    let y = currentCoordinates.y

    switch vector.direction {
    case .up:
      for dy in 1..<vector.distance {
        if currentGrid[y - dy] == nil { currentGrid[y - dy] = [:] }

        let oldPoint = currentGrid[y - dy]![x]
        switch oldPoint {
        case .none:
          currentGrid[y - dy]![x] = GridPoint(value: .vPath, wire: wire)
        case .some(let point) where point.value == .hPath:
          if point.wire != wire {
            currentGrid[y - dy]![x] = GridPoint(value: .cross, wire: wire)
          } else {
            currentGrid[y - dy]![x] = GridPoint(value: .ownCross, wire: wire)
          }
        default:
          fatalError("""
            unexpected value in grid.
            coord: (\(x), \(y - dy)):
            \(currentGrid[y - dy]![x]!),
            for vector: \(vector)
          """)
        }
      }
      if currentGrid[y - vector.distance] == nil { currentGrid[y - vector.distance] = [:] }

      currentGrid[y - vector.distance]![x] = GridPoint(value: .corner, wire: wire)
      currentCoordinates = (x: x, y: y - vector.distance)
    case .down:
      for dy in 1..<vector.distance {
        if currentGrid[y + dy] == nil { currentGrid[y + dy] = [:] }

        let oldPoint = currentGrid[y + dy]![x]
        switch oldPoint {
        case .none:
          currentGrid[y + dy]![x] = GridPoint(value: .vPath, wire: wire)
        case .some(let point) where point.value == .hPath:
          if point.wire != wire {
            currentGrid[y + dy]![x] = GridPoint(value: .cross, wire: wire)
          } else {
            currentGrid[y + dy]![x] = GridPoint(value: .ownCross, wire: wire)
          }
        default:
          fatalError("""
            unexpected value in grid.
            coord: (\(x), \(y)):
            \(currentGrid[y + dy]![x]!),
            for vector: \(vector)
          """)
        }
      }
      if currentGrid[y + vector.distance] == nil { currentGrid[y + vector.distance] = [:] }

      currentGrid[y + vector.distance]![x] = GridPoint(value: .corner, wire: wire)
      currentCoordinates = (x: x, y: y + vector.distance)
    case .left:
      for dx in 1..<vector.distance {
        let oldPoint = currentGrid[y]![x - dx]
        switch oldPoint {
        case .none:
          currentGrid[y]![x - dx] = GridPoint(value: .hPath, wire: wire)
        case .some(let point) where point.value == .vPath:
          if point.wire != wire {
            currentGrid[y]![x - dx] = GridPoint(value: .cross, wire: wire)
          } else {
            currentGrid[y]![x - dx] = GridPoint(value: .ownCross, wire: wire)
          }
        default:
          fatalError("""
            unexpected value in grid.
            coord: (\(x - dx), \(y)):
            \(currentGrid[y]![x - dx]!),
            for vector: \(vector)
          """)
        }
      }

      currentGrid[y]![x - vector.distance] = GridPoint(value: .corner, wire: wire)
      currentCoordinates = (x: x - vector.distance, y: y)
    case .right:
      for dx in 1..<vector.distance {
        let oldPoint = currentGrid[y]![x + dx]
        switch oldPoint {
        case .none:
          currentGrid[y]![x + dx] = GridPoint(value: .hPath, wire: wire)
        case .some(let point) where point.value == .vPath:
          if point.wire != wire {
            currentGrid[y]![x + dx] = GridPoint(value: .cross, wire: wire)
          } else {
            currentGrid[y]![x + dx] = GridPoint(value: .ownCross, wire: wire)
          }
        default:
          fatalError("""
            unexpected value in grid.
            coord: (\(x + dx), \(y)):
            \(currentGrid[y]![x + dx]!),
            for vector: \(vector)
          """)
        }
      }

      currentGrid[y]![x + vector.distance] = GridPoint(value: .corner, wire: wire)
      currentCoordinates = (x: x + vector.distance, y: y)
    }
    //swiftlint:enable identifier_name
  }

  mutating func resetToOrigin() {
    currentCoordinates = (x: 0, y: 0)
  }

  func nearestIntersectionDistance() -> Int {
    var closestIntersection = Int.max
    for xKey in currentGrid.keys {
      for yKey in currentGrid[xKey]!.keys where currentGrid[xKey]![yKey]!.value == .cross {
        closestIntersection = min(closestIntersection, abs(xKey) + abs(yKey))
      }
    }
    return closestIntersection
  }

  var description: String {
    let minX = currentGrid.keys.min()!
    let maxX = currentGrid.keys.max()!

    var minY = Int.max
    var maxY = Int.min

    for key in currentGrid.keys {
      minY = min(minY, currentGrid[key]!.keys.min()!)
      maxY = max(maxY, currentGrid[key]!.keys.max()!)
    }

    var string = ""
    //swiftlint:disable identifier_name
    for x in minX...maxX {
      for y in minY...maxY {
        string.append(currentGrid[x]?[y]?.value.rawValue ?? ".")
      }
      string.append("\n")
    }
    //swiftlint:enable identifier_name
    return string
  }
}

struct GridPoint {
  let value: GridValue
  let wire: Int
}

enum GridValue: Character {
  case origin = "o"
  case hPath = "-"
  case vPath = "|"
  case corner = "+"
  case cross = "X"
  case ownCross = "÷"
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
