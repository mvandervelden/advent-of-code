class Solution12: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    var grid = file.charsByLine

    var start: Point2D! = nil
    var end: Point2D! = nil

    for (i, line) in grid.enumerated() {
      for (j, char) in line.enumerated() {
        if char == "S" { start = Point2D(x: j, y: i) }
        if char == "E" { end = Point2D(x: j, y: i) }
      }
    }

    grid[start.y][start.x] = "a"
    grid[end.y][end.x] = "z"

    let astar = AStar(grid: grid)
    let path = astar.astar(start: start, goal: end)!

    return (path.count-1).description
  }

  func solve2() -> String {
    var grid = file.charsByLine

    var start: Point2D! = nil
    var end: Point2D! = nil
    var starts: [Point2D] = []
    for (i, line) in grid.enumerated() {
      for (j, char) in line.enumerated() {
        if char == "a" { starts.append(Point2D(x: j, y: i)) }
        if char == "S" { start = Point2D(x: j, y: i); starts.append(start) }
        if char == "E" { end = Point2D(x: j, y: i) }
      }
    }

    grid[start.y][start.x] = "a"
    grid[end.y][end.x] = "z"

    var minSteps = Int.max
    let astar = AStar(grid: grid)

    for s in starts {
      guard let path = astar.astar(start: s, goal: end) else { continue }
      minSteps = min(minSteps, path.count-1)
    }


    return minSteps.description
  }

  class AStar {
    let grid: [[Character]]

    lazy var maxX: Int = grid[0].count - 1
    lazy var maxY: Int = grid.count - 1
    let minX = 0
    let minY = 0
    let maxValue = Int(Character("z").asciiValue!)

    init(grid: [[Character]]) {
      self.grid = grid
    }

    func astar(start: Point2D, goal: Point2D) -> [Point2D]? {
      var closedSet: Set<Point2D> = []
      var openSet: Set<Point2D> = [start]
      var cameFrom: [Point2D: Point2D] = [:]
      var gScore: [Point2D: Int] = [start: 0]
      var fScore: [Point2D: Int] = [start: heuristicEstimate(start: start, goal: goal)]

      while !openSet.isEmpty {
        let current = openSet.min {
          let lhsScore = fScore[$0] ?? Int.max
          let rhsScore = fScore[$1] ?? Int.max
          return lhsScore < rhsScore
        }!

        if current == goal {
          print("total cost: ", gScore[current]!)
          return reconstruct(cameFrom, current: current)
        }

        openSet.remove(current)
        closedSet.insert(current)

        for neighbor in neighbors(current) {
          if closedSet.contains(neighbor.loc) {
            continue
          }

          let tentativeG = gScore[current]! + neighbor.cost

          if !openSet.contains(neighbor.loc) {
            openSet.insert(neighbor.loc)
          } else if tentativeG >= gScore[neighbor.loc] ?? Int.max {
            continue
          }

          cameFrom[neighbor.loc] = current
          gScore[neighbor.loc] = tentativeG
          fScore[neighbor.loc] = tentativeG + heuristicEstimate(start: neighbor.loc, goal: goal)
        }
      }

      return nil
    }

    private func heuristicEstimate(start: Point2D, goal: Point2D) -> Int {
      return abs(start.x - goal.x) + abs(start.y - goal.y)
    }

    private func reconstruct(_ cameFrom: [Point2D: Point2D], current: Point2D) -> [Point2D] {
      var current = current
      var totalPath = [current]
      while cameFrom[current] != nil {
        current = cameFrom[current]!
        totalPath.append(current)
      }
      return totalPath
    }

    private func neighbors(_ loc: Point2D) -> [(loc: Point2D, cost: Int)] {
      var locs: [(loc: Point2D, cost: Int)] = []

      let currentValue = Int(grid[loc.y][loc.x].asciiValue!)

      let neighborPoints = loc.nonDiagNeighbors(maxX: maxX, maxY: maxY)

      for pt in neighborPoints {
        let newValue = Int(grid[pt.y][pt.x].asciiValue!)
        if newValue <= currentValue + 1 {
          locs.append((loc: pt, cost: maxValue - newValue))
        }
      }

      return locs
    }
  }
}

