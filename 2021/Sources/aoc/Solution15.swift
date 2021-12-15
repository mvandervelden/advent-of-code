class Solution15: Solving {
  let file: File
  var grid: [[Int]] = []
  lazy var maxX = grid[0].count - 1
  lazy var maxY = grid.count - 1

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    grid = file.charsByLine.map { $0.map { Int(String($0))! } }

    let path = astar(start: Point2D(x: 0, y: 0), goal: Point2D(x: maxX, y: maxY))
    return path!.description
  }

  func solve2() -> String {
    let smallGrid = file.charsByLine.map { $0.map { Int(String($0))! } }
    let smallGridXCount = smallGrid[0].count
    let smallGridYCount = smallGrid.count

    grid = Array(repeating: Array(repeating: 0, count: smallGridXCount * 5), count: smallGridYCount * 5)

    for x in 0..<5 {
      for y in 0..<5 {
        let xOffset = smallGridXCount * x
        let yOffset = smallGridYCount * y

        for xx in 0..<smallGridXCount {
          for yy in 0..<smallGridYCount {
            let val = (((smallGrid[yy][xx] + x + y) - 1) % 9) + 1
            grid[yOffset + yy][xOffset + xx] = val
          }
        }
      }
    }
    // printGrid()

    let path = astar(start: Point2D(x: 0, y: 0), goal: Point2D(x: maxX, y: maxY))
    return path!.description
  }

  private func astar(start: Point2D, goal: Point2D) -> [Point2D]? {
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

    let neighborPoints = loc.nonDiagNeighbors(maxX: maxX, maxY: maxY)

    for pt in neighborPoints {
      locs.append((loc: pt, cost: grid[pt.y][pt.x]))
    }

    return locs
  }

  private func printGrid() {
    for line in grid {
      print(line.reduce("") {$0 + String($1) })
    }
  }
}
