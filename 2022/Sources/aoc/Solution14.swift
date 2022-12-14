class Solution14: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  var maxX = 0
  var maxY = 0
  var minX = Int.max
  let occupied: [Character] = ["#", "o"]

  func getRocks() -> [[Point2D]] {
    file.lines.map { line in
      line.components(separatedBy: " -> ").map { str in
        let elements = str.split(separator: ",")
        let x = Int(elements[0])!
        let y = Int(elements[1])!
        maxX = max(maxX, x)
        maxY = max(maxY, y)
        minX = min(minX, x)
        return Point2D(x: x, y: y)
      }
    }
  }

  func getGrid(rocks: [[Point2D]], addFloor: Bool = false) -> [[Character]] {
    if addFloor {
      minX -= maxY
      maxX += maxY
    }
    var grid: [[Character]] = Array(repeating: Array(repeating: ".", count:maxX-minX+1), count: maxY+1)

    for rock in rocks {
      var start = rock[0]

      for next in rock[1...] {
        let xLow = min(start.x, next.x)
        let xHigh = max(start.x, next.x)
        let yLow = min(start.y, next.y)
        let yHigh = max(start.y, next.y)

        for x in xLow...xHigh {
          for y in yLow...yHigh {
            grid[y][x-minX] = "#"
          }
        }
        start = next
      }
    }
    grid[0][500-minX] = "+"

    if addFloor {
      grid.append(Array(repeating: ".", count:maxX-minX+1))
      grid.append(Array(repeating: "#", count:maxX-minX+1))
    }

    return grid
  }

  func fallDownGrid(point: Point2D, grid: [[Character]]) -> Point2D {
    let x = point.x-minX
    let nextY = grid[point.y...].enumerated().first { occupied.contains($0.element[x]) }?.offset
    // print(nextY)
    return Point2D(x: point.x, y:point.y+(nextY ?? grid.count))
  }

  func solve1() -> String {
    let rocks = getRocks()
    var grid = getGrid(rocks: rocks)

    print(grid.prettyDescription)

    var fallenSandCount = 0
    var edgeReached = false
    // var sandDropped = 0

    while !edgeReached {
      // print("sand dropped", sandDropped)
      // sandDropped += 1
      var sandPosition = Point2D(x: 500, y: 0)
      var isFalling = true

      while isFalling {
        // print(grid.prettyDescription)

        // var next = sandPosition.down()
        var next = fallDownGrid(point: sandPosition, grid: grid)// sandPosition.down()

        // print(sandPosition, next)

        guard next.isIn(grid: grid, xOffset: minX) else {
          edgeReached = true
          break
        }

        if occupied.contains(grid[next.y][next.x-minX]) {
          next = next.left()

          guard next.isIn(grid: grid, xOffset: minX) else {
           edgeReached = true
            break
          }

          if occupied.contains(grid[next.y][next.x-minX]) {
            next = next.right(2)

            guard next.isIn(grid: grid, xOffset: minX) else {
              edgeReached = true
              break
            }

            if occupied.contains(grid[next.y][next.x-minX]) {
              // no way down: stop falling
              fallenSandCount += 1
              let drop = next.up().left()

              grid[drop.y][drop.x-minX] = "o"
              isFalling = false
              break
            }
          }
        }

        sandPosition = next
      }
    }

    print(grid.prettyDescription)
    print()

    return fallenSandCount.description
  }

  func solve2() -> String {
    let rocks = getRocks()
    var grid = getGrid(rocks: rocks, addFloor: true)

    print(grid.prettyDescription)

    var fallenSandCount = 0
    var edgeReached = false
    var sandDropped = 0

    while !edgeReached {
      print("sand dropped", sandDropped)
      sandDropped += 1
      var sandPosition = Point2D(x: 500, y: 0)
      var isFalling = true

      while isFalling {
        // print(grid.prettyDescription)

        // var next = sandPosition.down()
        var next = fallDownGrid(point: sandPosition, grid: grid)// sandPosition.down()

        // print(sandPosition, next)

        if next == Point2D(x: 500, y: 0) {
          edgeReached = true
          break
        }

        guard next.isIn(grid: grid, xOffset: minX) else {
          edgeReached = true
          break
        }

        if occupied.contains(grid[next.y][next.x-minX]) {
          next = next.left()

          guard next.isIn(grid: grid, xOffset: minX) else {
           edgeReached = true
            break
          }

          if occupied.contains(grid[next.y][next.x-minX]) {
            next = next.right(2)

            guard next.isIn(grid: grid, xOffset: minX) else {
              edgeReached = true
              break
            }

            if occupied.contains(grid[next.y][next.x-minX]) {
              // no way down: stop falling
              fallenSandCount += 1
              let drop = next.up().left()
              grid[drop.y][drop.x-minX] = "o"
              isFalling = false
              break
            }
          }
        }

        sandPosition = next
      }
    }

    print(grid.prettyDescription)
    print()

    return fallenSandCount.description
  }
}
