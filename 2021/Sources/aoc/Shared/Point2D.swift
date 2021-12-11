struct Point2D: Hashable, CustomStringConvertible {
  let x: Int
  let y: Int

  init(x: Int, y: Int) {
    self.x = x
    self.y = y
  }

  init(string: String) {
    let parts = string.split(separator: ",").map { Int($0)! }
    x = parts[0]
    y = parts[1]
  }

  var description: String { "(\(x),\(y))" }

  func neighbors(maxX: Int, maxY: Int) -> [Point2D] {
    let xMin = max(x - 1, 0)
    let yMin = max(y - 1, 0)
    let xMax = min(x + 1, maxX)
    let yMax = min(y + 1, maxY)

    var neighbors: [Point2D] = []

    for xx in xMin...xMax {
      for yy in yMin...yMax {
        if xx == x && yy == y { continue }

        neighbors.append(Point2D(x: xx, y: yy))
      }
    }

    return neighbors
  }
}