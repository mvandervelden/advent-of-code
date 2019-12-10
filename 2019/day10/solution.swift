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
    let input = file.lines.map(Array.init)
    var grid: [Int: [Int: [(x: Int, y: Int, angle: Double)]]] = [:]

    for (y, line) in input.enumerated() {
      for (x, item) in line.enumerated() where item == "#" {
        grid[y, default: [:]][x] = []
      }
    }

    for (y, line) in grid {
      for x in line.keys {
        for (otherY, otherLine) in grid {
          for otherX in otherLine.keys where !(otherX == x && otherY == y) {
            let diff = (dx: otherX - x, dy: otherY - y)
            let angle = atan2(Double(diff.dx), Double(diff.dy))
            // if x == 2 && y == 2 {
            //   print("testing (\(otherX),\(otherY))")
            //   print("diff: \(diff)")
            //   print("angle: \(angle)")
            // }
            var foundMatch = false
            for (matchIndex, match) in grid[y]![x]!.enumerated() where angle == match.angle {
              foundMatch = true
              let matchDiff = (dx: match.x - x, dy: match.y - y)
              if abs(matchDiff.dx) + abs(matchDiff.dy) > abs(diff.dx) + abs(diff.dy) {
                grid[y]![x]![matchIndex] = (x: x, y: y, angle: angle)
              }
              break
            }
            if !foundMatch {
              grid[y]![x]!.append((x: x, y: y, angle: angle))
            }
          }
        }
      }
    }

    var maxVal = 0
    var max = (x: -1, y: -1)

    for y in grid.keys {
      for x in grid[y]!.keys {
        let val = grid[y]![x]!.count
        if val > maxVal {
          maxVal = val
          max = (x: x, y: y)
        }
      }
    }

    // let minY = grid.keys.min()!
    // let maxY = grid.keys.max()!
    // let minX = grid.values.flatMap { $0.keys }.min()!
    // let maxX = grid.values.flatMap { $0.keys }.max()!

    // for y in minY...maxY {
    //   for x in minX...maxX {
    //     if let val = grid[y]?[x]?.count {
    //       print("\(val) ", terminator: "")
    //     } else {
    //       print(" .  ", terminator: "")
    //     }
    //   }
    //   print("")
    // }

    return "max: \(maxVal), coord: (\(max.x),\(max.y))"
  }

  private func solveTwo(file: File) -> String {
    let input = file.lines.map(Array.init)
    var grid: [Int: [Int: [(x: Int, y: Int, angle: Double)]]] = [:]

    for (y, line) in input.enumerated() {
      for (x, item) in line.enumerated() where item == "#" {
        grid[y, default: [:]][x] = []
      }
    }

    let x = 11
    let y = 13
    var angles: [(angle: Double, asteroids: [(dist: Int, x: Int, y: Int)])] = []

    for (otherY, otherLine) in grid {
      for otherX in otherLine.keys where !(otherX == x && otherY == y) {
        let diff = (dx: otherX - x, dy: otherY - y)
        let angle = atan2(Double(diff.dx), Double(diff.dy))
        let dist = abs(diff.dx) + abs(diff.dy)

        if let existingAngle = angles.enumerated().first(where: { $0.element.angle == angle }) {
          angles[existingAngle.offset].asteroids.append((dist: dist, x: otherX, y: otherY))
        } else {
          angles.append((angle: angle, asteroids: [(dist: dist, x: otherX, y: otherY)]))
        }
      }
    }

    // .#.
    // ###
    // .#.
    // angles: up: π
    //         right: π/2
    //         down: 0
    //         left: -π/2
    //         up: -π

    for i in 0..<angles.count {
      angles[i].asteroids = angles[i].asteroids.sorted { $0.dist < $1.dist }
    }

    angles.sort { $0.angle > $1.angle }

    var destroyed = 0
    var currentIndex = 0
    var lastDestroyed = (dist: -1, x: -1, y: -1)

    while destroyed < 200 && angles.count > 0 {
      var current = angles[currentIndex]
      lastDestroyed = current.asteroids.first!
      print("destroyed: angle: \(current.angle): \(lastDestroyed)")
      current.asteroids.removeFirst()
      destroyed += 1

      if current.asteroids.isEmpty {
        angles.remove(at: currentIndex)
      } else {
        angles[currentIndex] = current
        currentIndex += 1
      }
      if angles.count == 0 { break }
      currentIndex = currentIndex % angles.count
    }


    // let minY = grid.keys.min()!
    // let maxY = grid.keys.max()!
    // let minX = grid.values.flatMap { $0.keys }.min()!
    // let maxX = grid.values.flatMap { $0.keys }.max()!

    // for y in minY...maxY {
    //   for x in minX...maxX {
    //     if let val = grid[y]?[x]?.count {
    //       print("\(val) ", terminator: "")
    //     } else {
    //       print(" .  ", terminator: "")
    //     }
    //   }
    //   print("")
    // }

    return "\(lastDestroyed)"
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
    return lines.map { $0.split(separator: " ").map(String.init) }
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
