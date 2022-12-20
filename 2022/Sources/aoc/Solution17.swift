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

    var grid: [Int: [Int: Character]] = [:]
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
        // print(rocksFallen, "\(gust)")
        // print(grid.prettyDescriptionAdding(rocks[rockInd], x: rockX, y: rockY))
      } else {
        // fall
        rockY -= 1
      }
      // print(gustInd, "\(gust)")
      // print(grid.prettyDescriptionAdding(rocks[rockInd], x: rockX, y: rockY))
    }
    print(grid.topHash)
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

    var loopDetection: [Int: (Int, Int)] = [:]
    var loopDet2: [Int: [([Int], Int, Int)]] = [:]

    var curLoop2: [Int] = []
    var fallenLast = 0
    var heightLast = 0

    var limit = 1_000_000_000_000

    while rocksFallen < limit {
      let gust = gusts[gustInd]
      gustInd = (gustInd + 1)%gusts.count

      if rocksFallen%1_000_000 == 0 {
        print(rocksFallen)
      }

      // print(gustInd, rockInd)

      if gustInd == 0 {
        if let prevLoops = loopDet2[rockInd] {
          if let loop = prevLoops.first(where: { $0.0 == curLoop2 }) {
            print("loop found!", loop)
            print("current:", curLoop2, rocksFallen, grid.highestPoint)
            let startOffset = loop.1
            let cycleLength = rocksFallen - startOffset
            let loopCount = (limit-startOffset)/cycleLength
            let leftover = (limit-startOffset)%cycleLength
            let startHeight = loop.2
            let loopHeight = grid.highestPoint - loop.2
            let endLoopheight = startHeight + loopCount * loopHeight

            print("startOffset:", startOffset, "cycle:", cycleLength, "loops until end", loopCount, "leftover", leftover, "end loop height", endLoopheight)
            limit = rocksFallen + leftover
            continue
            // TODO
            // break
          }
        }
        loopDet2[rockInd, default: []].append((curLoop2, rocksFallen, grid.highestPoint))
        curLoop2 = [rockInd]
      } else {
        curLoop2.append(rockInd)
      }


      if gustInd == 0 && rockInd == 0 {
        print("fallenSinceLast", rocksFallen - fallenLast, "heightSinceLast", grid.highestPoint - heightLast)

        fallenLast = rocksFallen
        heightLast = grid.highestPoint
      }

      if gustInd == 0 && rockInd == 0 && rockY == grid.highestPoint + 4 {
        // Try to find loop
        if let prevFallen = loopDetection[grid.topHash] {
          // print("loop found")
          print(prevFallen.0, rocksFallen, prevFallen.1, grid.highestPoint)
          break
        } else {
          print("No loop found, rocky", rockY, "highest+4", grid.highestPoint + 4)
          loopDetection[grid.topHash] = (rocksFallen, grid.highestPoint)
        }
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
        // print(rocksFallen, "\(gust)")
        // print(grid.prettyDescriptionAdding(rocks[rockInd], x: rockX, y: rockY))
      } else {
        // fall
        rockY -= 1
      }
      // print(gustInd, "\(gust)")
      // print(grid.prettyDescriptionAdding(rocks[rockInd], x: rockX, y: rockY))
    }

    return grid.highestPoint.description
  }
}

typealias LazyGrid = [Int: [Int: Character]]

extension LazyGrid {
  func prettyDescriptionAdding(_ rock: Rock, x: Int, y: Int) -> String {
    var grid = self
    grid.addRock(rock, x: x, y: y, symbol: "@")

    return grid.prettyDescription
  }

  var prettyDescription: String {
    (0...highestPoint).map { yInv in
      let y = highestPoint - yInv

      return "|" + String((0...self[0]!.keys.max()!).map { x in
        return self[y]?[x] ?? "."
      }) + "|"
    }.joined(separator: "\n")
  }

  var highestPoint: Int {
    return keys.max()!
  }

  func hits(_ rock: Rock, x: Int, y: Int) -> Bool {
    // print("gettingMax")
    guard y > 0 else { return true }// hits bottom
    guard x >= 0, x + rock.width <= 7 else { return true } // hits edges
    // print("GotMax")

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

  var topHash: Int {
    let top = highestPoint

    var value = 0

    // print((0...4).map { yInv in
    //   let y = top - yInv

    //   return "|" + String((0...self[0]!.keys.max()!).map { x in
    //     return self[y]?[x] ?? "."
    //   }) + "|"
    // }.joined(separator: "\n"))

    for (i, y) in ((top-4)...top).enumerated() {
      let row = self[y]!
      var val = 0
      for x in row.keys {
        val += 1 << x
        // print("x", x, "adding", 1 << x, "val", val)
      }

      value += val * Int(pow(Double(10), Double(i)))
      // print("y", y, "adding", val * Int(pow(Double(10), Double(i))), "value", value)
    }

    return value
  }

  mutating func clean() {
    let lowestPoint = keys.min()!

    guard highestPoint - lowestPoint > 100 else { return }
    // print("cleaning")
    for i in lowestPoint...(lowestPoint + 50) {
      self[i] = nil
    }
  }
}
