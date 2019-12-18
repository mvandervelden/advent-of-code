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

  var planets: [Planet] = []

  private func solveOne(file: File) -> String {
    let locations = file.lines.map(Point.init)
    let velocities = Array(repeating: Point(x: 0, y: 0, z: 0), count: 4)
    planets = zip(locations, velocities).map(Planet.init)

    let stepsTotal = 1000

    for _ in 0..<stepsTotal {
      for planet in planets {
        print(planet)
      }
      print("")
      doStep()
    }

    for planet in planets {
      print(planet)
    }
    let total = planets.map { $0.energy }.reduce(0, +)
    return "total: \(total)"
  }

  private func solveTwo(file: File) -> String {
    let locations = file.lines.map(Point.init)
    let velocities = Array(repeating: Point(x: 0, y: 0, z: 0), count: 4)
    planets = zip(locations, velocities).map(Planet.init)

    let stepsTotal = 10

    for _ in 0..<stepsTotal {
      printPlanets(planets)
      for planet in planets {
        print(planet)
      }
      print("")
      doStep()
    }

    for planet in planets {
      print(planet)
    }
    let total = planets.map { $0.energy }.reduce(0, +)
    return "total: \(total)"
  }

  private func printPlanets(_ planets: [Planet]) {
    let minX = ([0] + planets.map { $0.location.x }).min()!
    let maxX = ([0] + planets.map { $0.location.x }).max()!
    let minY = ([0] + planets.map { $0.location.y }).min()!
    let maxY = ([0] + planets.map { $0.location.y }).max()!

    var grid: [Int: [Int: String]] = [:]

    grid[0, default:[:]][0] = "+"


    for (index, planet) in planets.enumerated() {
      grid[planet.location.y, default: [:]][planet.location.x] = planet.location.z.description
    }


    for y in minY...maxY {
      for x in minX...maxX {
        print((grid[y]?[x] ?? "."), terminator: "")
      }
      print("")
    }
  }

  private func doStep() {
    for i in 0..<4 {
      let loc = planets[i].location
      var newVelocity = planets[i].velocity

      for otherPlanet in planets where loc != otherPlanet.location {
        let other = otherPlanet.location
        if loc.x < other.x {
          newVelocity.x += 1
        } else if loc.x > other.x {
          newVelocity.x -= 1
        }

        if loc.y < other.y {
          newVelocity.y += 1
        } else if loc.y > other.y {
          newVelocity.y -= 1
        }

        if loc.z < other.z {
          newVelocity.z += 1
        } else if loc.z > other.z {
          newVelocity.z -= 1
        }
      }
      planets[i].velocity = newVelocity
    }

    for i in 0..<4 {
      var newLocation = planets[i].location
      let velocity = planets[i].velocity
      newLocation.x += velocity.x
      newLocation.y += velocity.y
      newLocation.z += velocity.z
      planets[i].location = newLocation
    }
  }
}

struct Planet: CustomStringConvertible, Equatable {
  var location: Point
  var velocity: Point

  var energy: Int {
    print("energy: \(location.sum) * \(velocity.sum)")
    return location.sum * velocity.sum
  }

  var description: String {
    return "pos=\(location), vel=\(velocity)"
  }
}

struct Point: CustomStringConvertible, Equatable {
  var x: Int
  var y: Int
  var z: Int

  var sum: Int {
    return abs(x) + abs(y) + abs(z)
  }

  static let removeChars: Set<Character> = ["<", ">", " "]

  init(x: Int, y: Int, z: Int) {
    self.x = x
    self.y = y
    self.z = z
  }

  init(string: String) {
    var string = string
    string.removeAll { Point.removeChars.contains($0) }
    let elements: [Int] = string.split(separator: ",").map { elem in
      // print(elem)
      let last = elem.split(separator: "=").last!
      // print(last)
      return Int(String(last))!
    }
    x = elements[0]
    y = elements[1]
    z = elements[2]
  }

  var description: String {
    return "<x=\(x), y=\(y), z=\(z)>"
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
