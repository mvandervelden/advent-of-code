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

  var dungeon: Dungeon!

  private func solveOne(file: File) -> String {
    dungeon = file.dungeon
    print(dungeon.description)
    print(dungeon.remainingKeys(grid: dungeon.grid))
    return dungeon.getReachableKeys(dungeon.grid).description
  }

  private func solveTwo(file: File) -> String {
    return "input: \(file.filename)\ncontent:\n\(file.words)\nresult 2"
  }
}

class Dungeon: CustomStringConvertible {
  var grid: [[Character]]

  func remainingKeys(grid: [[Character]]) -> [Location] {
    var keys: [Location] = []
    for y in 0..<grid.count {
      for x in 0..<grid[y].count {
        let elem = grid[y][x]
        if keyRange.contains(elem) {
          keys.append(Location(x: x, y: y, type: elem))
        }
      }
    }
    return keys
  }

  func remainingDoors(grid: [[Character]]) -> [Location] {
    var keys: [Location] = []
    for y in 0..<grid.count {
      for x in 0..<grid[y].count {
        let elem = grid[y][x]
        if doorRange.contains(elem) {
          keys.append(Location(x: x, y: y, type: elem))
        }
      }
    }
    return keys
  }


  let keyRange: ClosedRange<Character> = "a"..."z"
  let doorRange: ClosedRange<Character> = "A"..."Z"

  init(file: File) {
    grid = file.lines.map { $0.map { $0 } }
  }

  func getReachableKeys2(_ grid: [[Character]], cost: Int = 0, depth: Int = 0) -> Int {
    let path = astar2(start: self.remainingKeys(grid: grid), grid: grid)
    print(path)
  }
  func getReachableKeys(_ grid: [[Character]], cost: Int = 0, depth: Int = 0) -> Int {
    let position = getPosition(grid)
    // print(depth, cost)
    // if depth > 3 { print("TOO DEEP: \(grid)");return cost}

    if hasKeys(grid) {
      let remainingKeys = self.remainingKeys(grid: grid)
      var lowestCost = Int.max
      for key in remainingKeys {
        if depth == 0 { print("searching with 1st key: \(key)") }
        if depth == 1 { print("searching with 2nd key: \(key)") }
        if depth == 2 { print("searching with 3rd key: \(key)") }
        if depth == 3 { print("searching with 4th key: \(key)") }
        if let pathFound = astar(start: position, goal: key, grid: grid) {
          let newCost = pathFound.count - 1
          var newGrid = grid
          newGrid[position.y][position.x] = "."
          newGrid[key.y][key.x] = "@"
          let doorType = key.type.uppercased().first!
          for y in 0..<newGrid.count {
            for x in 0..<newGrid[y].count {
              if newGrid[y][x] == doorType {
                newGrid[y][x] = "."
              }
            }
          }

          let subCost = getReachableKeys(newGrid, cost: cost + newCost, depth: depth + 1)
          lowestCost = min(lowestCost, subCost)
        }
      }
      return lowestCost
    } else {
      lowestFoundYet = min(lowestFoundYet, cost)
      print("No more keys! lowestYet: ", lowestFoundYet)
      return cost
    }
  }

  var lowestFoundYet = Int.max
  func getPosition(_ grid: [[Character]]) -> Location {
    for y in 0..<grid.count {
      for x in 0..<grid[y].count where grid[y][x] == "@" {
        return Location(x: x, y: y, type: "@")
      }
    }
    fatalError("did not found start position")
  }

func astar2(start: Set<Location>, grid: [[Character]]) -> [Set<Location>]? {
    let goal: Set<Location> = []
    // print("start: \(start), goal: \(goal)")
    var closedSet: Set<Set<Location>> = []
    var openSet: Set<Set<Location>> = [start]
    var cameFrom: [Set<Location>: Set<Location>] = [:]
    var gScore: [Set<Location>: Int] = [start: 0]
    var fScore: [Set<Location>: Int] = [start: start.count]

    while !openSet.isEmpty {
      // print("openSet", openSet)
      // print("closedSet", closedSet)
      // print("cameFrom", cameFrom)
      // print("gScore", gScore)
      // print("fScore", fScore)
      // print("finding current")
      let current = openSet.min {
        let lhsScore = fScore[$0] ?? Int.max
        let rhsScore = fScore[$1] ?? Int.max
        return lhsScore < rhsScore //|| (lhsScore == rhsScore && ($0.y < $1.y || ($0.y == $1.y && $0.x < $1.x)))
      }!
      // let current = openSet.min { fScore[$0] ?? Int.max < fScore[$1] ?? Int.max }!
      // print("current", current, fScore[current]!)
      // if fScore[current]! > 45 {
      //     print("openSet", openSet)
      //     print("closedSet", closedSet)
      //     print("cameFrom", cameFrom)
      //     print("gScore", gScore)
      //     print("fScore", fScore)
      //     fatalError()
      // }
      if current == goal {
          // print("total cost: ", gScore[current]!)
          // print("path found to ", goal)
          return reconstruct2(cameFrom, current: current)
      }

      openSet.remove(current)
      closedSet.insert(current)

      for neighbor in neighbors2(current, grid: grid) {
        // print("neighbor", neighbor)
        if closedSet.contains(neighbor.loc) {
          continue
        }

        let tentativeG = gScore[current]! + neighbor.cost// + 1000000 + neighbor.y * 100 + neighbor.x

        if !openSet.contains(neighbor.loc) {
          openSet.insert(neighbor.loc)
        } else if tentativeG >= gScore[neighbor.loc] ?? Int.max {
          continue
        }
        // print("Adding neighbor")
        cameFrom[neighbor.loc] = current
        gScore[neighbor.loc] = tentativeG
        fScore[neighbor.loc] = tentativeG + neighbor.loc.count
        // print("Added neighbor")
      }
    }
    // print("no path found to \(goal)")
    return nil
  }

func reconstruct2(_ cameFrom: [Set<Location>: Set<Location>], current: Set<Location>) -> [Set<Location>] {
    var current = current
    var totalPath = [current]
    while cameFrom[current] != nil {
      current = cameFrom[current]!
      totalPath.append(current)
    }
    return totalPath
  }

  func neighbors2(_ loc: Set<Location>, grid: [[Character]]) -> [(loc: Set<Location>, cost: Int)] {
    var locs: [(loc: Set<Location>, cost: Int)] = []
    let current = getPosition(grid)
    for location in loc {
      if let path = astar(start: current, goal: location, grid: grid) {
        var newLoc = loc
        newLoc.remove(location)
        locs.append((loc: newLoc, cost: path.count - 1))
      }
    }
    return locs
  }

  func astar(start: Location, goal: Location, grid: [[Character]]) -> [Location]? {
    // print("start: \(start), goal: \(goal)")
    var closedSet: Set<Location> = []
    var openSet: Set<Location> = [start]
    var cameFrom: [Location: Location] = [:]
    var gScore: [Location: Int] = [start: 0]
    var fScore: [Location: Int] = [start: heuristicEstimate(start: start, goal: goal)]

    while !openSet.isEmpty {
      // print("openSet", openSet)
      // print("closedSet", closedSet)
      // print("cameFrom", cameFrom)
      // print("gScore", gScore)
      // print("fScore", fScore)
      // print("finding current")
      let current = openSet.min {
        let lhsScore = fScore[$0] ?? Int.max
        let rhsScore = fScore[$1] ?? Int.max
        return lhsScore < rhsScore //|| (lhsScore == rhsScore && ($0.y < $1.y || ($0.y == $1.y && $0.x < $1.x)))
      }!
      // let current = openSet.min { fScore[$0] ?? Int.max < fScore[$1] ?? Int.max }!
      // print("current", current, fScore[current]!)
      // if fScore[current]! > 45 {
      //     print("openSet", openSet)
      //     print("closedSet", closedSet)
      //     print("cameFrom", cameFrom)
      //     print("gScore", gScore)
      //     print("fScore", fScore)
      //     fatalError()
      // }
      if current.x == goal.x && current.y == goal.y {
          // print("total cost: ", gScore[current]!)
          // print("path found to ", goal)
          return reconstruct(cameFrom, current: current)
      }

      openSet.remove(current)
      closedSet.insert(current)

      for neighbor in neighbors(current, grid: grid) {
        // print("neighbor", neighbor)
        if closedSet.contains(neighbor.loc) {
          continue
        }

        let tentativeG = gScore[current]! + neighbor.cost// + 1000000 + neighbor.y * 100 + neighbor.x

        if !openSet.contains(neighbor.loc) {
          openSet.insert(neighbor.loc)
        } else if tentativeG >= gScore[neighbor.loc] ?? Int.max {
          continue
        }
        // print("Adding neighbor")
        cameFrom[neighbor.loc] = current
        gScore[neighbor.loc] = tentativeG
        fScore[neighbor.loc] = tentativeG + heuristicEstimate(start: neighbor.loc, goal: goal)
        // print("Added neighbor")
      }
    }
    // print("no path found to \(goal)")
    return nil
  }

  func heuristicEstimate(start: Location, goal: Location) -> Int {
    return abs(start.x - goal.x) + abs(start.y - goal.y)
  }

  func reconstruct(_ cameFrom: [Location: Location], current: Location) -> [Location] {
    var current = current
    var totalPath = [current]
    while cameFrom[current] != nil {
      current = cameFrom[current]!
      totalPath.append(current)
    }
    return totalPath
  }

  func neighbors(_ loc: Location, grid: [[Character]]) -> [(loc: Location, cost: Int)] {
    var locs: [(loc: Location, cost: Int)] = []

    // print("check up & left")
    if loc.x > 0 && isFree(grid[loc.y][loc.x - 1]) {
      // print("check left")
      locs.append((loc: Location(x: loc.x-1, y: loc.y, type: loc.type), cost: 1))
    }
    if loc.y > 0 && isFree(grid[loc.y - 1][loc.x]) {
      // print("check up")
      locs.append((loc: Location(x: loc.x, y: loc.y - 1, type: loc.type), cost: 1))
    }

    // print("explore right and below")
    if loc.x + 1 < grid[0].count && isFree(grid[loc.y][loc.x + 1]) {
      // print("explore right")
      locs.append((loc: Location(x: loc.x+1, y: loc.y, type: loc.type), cost: 1))
    }
    if loc.y + 1 < grid.count && isFree(grid[loc.y+1][loc.x]) {
      // print("explore below")
      locs.append((loc: Location(x: loc.x, y: loc.y+1, type: loc.type), cost: 1))
    }

    // print("found neighbors", locs)
    return locs
  }

  private func isFree(_ char: Character) -> Bool {
    if char == "#" { return false }
    if doorRange.contains(char) { return false }
    return true
  }

  private func hasKeys(_ grid: [[Character]]) -> Bool {
    for line in grid {
      for elem in line where keyRange.contains(elem) {
        return true
      }
    }
    return false
  }

  var description: String {
    var string = ""
    for y in grid {
      for x in y {
        string.append(x)
      }
      string.append("\n")
    }
    return string
  }
}

struct Location: Hashable, CustomStringConvertible {
  let x: Int
  let y: Int
  let type: Character

  var description: String {
    return "(\(x),\(y)):\(type)"
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

  lazy var dungeon: Dungeon = {
    return Dungeon(file: self)
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
