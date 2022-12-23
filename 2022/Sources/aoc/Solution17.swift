import Foundation

enum Rock: String, CaseIterable {
  case row = "-"
  case plus = "+"
  case j = "⌟"
  case col = "|"
  case square = "□"

  var gridShape: [Point2D] {
    switch self {
    case .row: return [Point2D(x:0, y:0), Point2D(x:1, y:0), Point2D(x:2, y:0), Point2D(x:3, y:0)]
    case .plus: return [Point2D(x:1, y:0), Point2D(x:0, y:1), Point2D(x:1, y:1), Point2D(x:2, y:1), Point2D(x:1, y:2)]
    case .j: return [Point2D(x:0, y:0), Point2D(x:1, y:0), Point2D(x:2, y:0), Point2D(x:2, y:1), Point2D(x:2, y:2)]
    case .col: return [Point2D(x:0, y:0), Point2D(x:0, y:1), Point2D(x:0, y:2), Point2D(x:0, y:3)]
    case .square: return [Point2D(x:0, y:0), Point2D(x:0, y:1), Point2D(x:1, y:0), Point2D(x:1, y:1)]
    }
  }

  var height: Int {
    switch self {
    case .row: return 1
    case .plus: return 3
    case .j: return 3
    case .col: return 4
    case .square: return 2
    }
  }

  var width: Int {
    switch self {
    case .row: return 4
    case .plus: return 3
    case .j: return 3
    case .col: return 1
    case .square: return 2
    }
  }
}

class Solution17: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let gusts = file.charsByLine[0]
    let rocks = Rock.allCases

    var grid: LazyGrid = [:]
    grid[0] = (0..<7).reduce(into: [:]) {
      $0[$1] = "-"
    }

    var rockInd = 0
    var rockY = grid.highestPoint + 4
    var rockX = 2
    var rocksFallen = 0
    var gustInd = 0

    while rocksFallen < 2022 {
      let gust = gusts[gustInd]
      gustInd = (gustInd + 1)%gusts.count

      let rock = rocks[rockInd]

      // gust process
      switch gust {
      case ">" where !grid.hits(rock, x: rockX + 1, y: rockY):
        rockX += 1
      case "<" where !grid.hits(rock, x: rockX - 1, y: rockY):
        rockX -= 1
      case ">", "<":
        break
      default: fatalError("unexpected gust '\(gust)'")
      }

      // fall process
      if grid.hits(rock, x: rockX, y: rockY - 1) {
        // fallen
        grid.addRock(rock, x: rockX, y: rockY)
        rocksFallen += 1
        rockInd = (rockInd + 1)%Rock.allCases.count
        rockY = grid.highestPoint + 4
        rockX = 2
      } else {
        // fall
        rockY -= 1
      }
    }
    return grid.highestPoint.description
  }

  func solve2() -> String {
    let gusts = file.charsByLine[0]
    let rocks = Rock.allCases

    var grid: [Int: [Int: Character]] = [:]
    grid[0] = (0..<7).reduce(into: [:]) {
      $0[$1] = "-"
    }

    var rockInd = 0
    var rockY = grid.highestPoint + 4
    var rockX = 2
    var rocksFallen = 0
    var gustInd = 0

    var loopDetection: [Int: [(loop: [Int], rockX: Int, relRockY: Int, rocksFallen: Int, finalHeight: Int, grid: LazyGrid)]] = [:]
    var curLoop: [Int] = []
    var detectLoops = true

    let limit = 1_000_000_000_000

    while rocksFallen < limit {
      let gust = gusts[gustInd]
      gustInd = (gustInd + 1)%gusts.count

      if detectLoops, gustInd == 0 {
        if let prevLoops = loopDetection[rockInd] {
          if let loop = prevLoops.first(where: { $0.loop == curLoop && $0.rockX == rockX && $0.relRockY == rockY - grid.highestPoint }) {
            print("loop found!", loop.loop.count, loop.rockX, loop.relRockY, loop.rocksFallen, loop.finalHeight)
            print("current:", curLoop.count, rockX, rockY - grid.highestPoint, rocksFallen, grid.highestPoint)
            // print(loop.grid.prettyDescriptionAdding(rocks[rockInd], x: loop.rockX, y: loop.finalHeight + loop.relRockY))
            let startOffset = loop.rocksFallen
            let cycleLength = rocksFallen - startOffset
            let loopCount = (limit-startOffset)/cycleLength
            let leftover = ((limit-startOffset)%cycleLength)
            let startHeight = loop.finalHeight
            let loopHeight = grid.highestPoint - loop.finalHeight
            let endLoopHeight = startHeight + loopCount * loopHeight

            print("startOffset:", startOffset, "cycle:", cycleLength, "loops until end", loopCount, "leftover", leftover, "end loop height", endLoopHeight)
            // print(grid.prettyDescriptionAdding(rocks[rockInd], x: rockX, y: rockY))

            // bootstrap to last few rocks
            rocksFallen = limit - leftover
            let gridOffset = endLoopHeight - grid.highestPoint
            var newGrid: LazyGrid = [:]
            for (k, v) in grid {
              newGrid[k+gridOffset] = v
            }

            grid = newGrid
            detectLoops = false
          }
        }
        loopDetection[rockInd, default: []].append((loop: curLoop, rockX: rockX, relRockY: rockY - grid.highestPoint, rocksFallen: rocksFallen, finalHeight: grid.highestPoint, grid: grid))
        curLoop = [rockInd]
      } else {
        curLoop.append(rockInd)
      }

      let rock = rocks[rockInd]

      // gust process
      switch gust {
      case ">" where !grid.hits(rock, x: rockX + 1, y: rockY):
        rockX += 1
      case "<" where !grid.hits(rock, x: rockX - 1, y: rockY):
        rockX -= 1
      case ">", "<":
        break
      default: fatalError("unexpected gust '\(gust)'")
      }

      // fall process
      if grid.hits(rock, x: rockX, y: rockY - 1) {
        // fallen
        grid.addRock(rock, x: rockX, y: rockY)
        grid.clean()

        rocksFallen += 1
        rockInd = (rockInd + 1)%Rock.allCases.count
        rockY = grid.highestPoint + 4
        rockX = 2
      } else {
        // fall
        rockY -= 1
      }
    }

    // print(grid.prettyDescriptionAdding(rocks[rockInd], x: rockX, y: rockY))
    return (grid.highestPoint + 6).description
  }
}

extension LazyGrid {
  func prettyDescriptionAdding(_ rock: Rock, x: Int, y: Int) -> String {
    var grid = self
    grid.addRock(rock, x: x, y: y, symbol: "@")

    return grid.prettyDescriptionInvY
  }

  var prettyDescriptionInvY: String {
    let lowestPoint = keys.min()!
    return (lowestPoint...highestPoint).map { yInv in
      let y = (highestPoint - yInv) + lowestPoint

      return "\(y)|" + String((0..<7).map { x in
        return self[y]?[x] ?? "."
      }) + "|"
    }.joined(separator: "\n")
  }

  var highestPoint: Int {
    return keys.max()!
  }

  func hits(_ rock: Rock, x: Int, y: Int) -> Bool {
    guard y > 0 else { return true }// hits bottom
    guard x >= 0, x + rock.width <= 7 else { return true } // hits edges

    return !rock.gridShape.lazy.map {
      point in Point2D(x: x + point.x, y: y + point.y)
    }.allSatisfy { point in
      self[point.y]?[point.x] == nil
    }
  }

  mutating func addRock(_ rock: Rock, x: Int, y: Int, symbol: Character = "#") {
    let rockPoints = rock.gridShape.map { point in Point2D(x: x + point.x, y: y + point.y) }

    for point in rockPoints {
      self[point.y, default: [:]][point.x] = symbol
    }
  }

  mutating func clean() {
    let lowestPoint = keys.min()!

    guard highestPoint - lowestPoint > 100 else { return }

    for i in lowestPoint...(lowestPoint + 50) {
      self[i] = nil
    }
  }
}
