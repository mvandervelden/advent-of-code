class Solution05: Solving {
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
  }

  struct Vector2D: CustomStringConvertible {
    let start: Point2D
    let end: Point2D

    init(string: String) {
      let parts = string.components(separatedBy: " -> ").map(Point2D.init)
      start = parts[0]
      end = parts[1]
    }

    var isHorVert: Bool { start.x == end.x || start.y == end.y }

    var isDiagonal: Bool {
      let dx = abs(start.x - end.x)
      let dy = abs(start.y - end.y)
      return dx == dy
    }

    var allPointsIfHorVert: [Point2D] {
      let xes = [start.x, end.x].sorted()
      let yes = [start.y, end.y].sorted()
      var points: [Point2D] = []
      for x in xes[0]...xes[1] {
        for y in yes[0]...yes[1] {
          points.append(Point2D(x: x, y: y))
        }
      }
      return points
    }

    var allPointsIfDiagonal: [Point2D] {
      let dx = start.x - end.x
      let dy = start.y - end.y

      let d = abs(dx)
      let itx = dx > 0 ? -1 : 1
      let ity = dy > 0 ? -1 : 1

      var curX = start.x
      var curY = start.y

      var points: [Point2D] = []

      for _ in 0...d {
        points.append(Point2D(x: curX, y: curY))
        curX += itx
        curY += ity
      }

      return points
    }

    var description: String { "\(start.x),\(start.y) -> \(end.x),\(end.y)" }
  }

  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let lines = file.lines.map(Vector2D.init)

    let horVertLines = lines.filter(\.isHorVert)

    var seenPoints: [Point2D: Int] = [:]

    for line in horVertLines {
      for point in line.allPointsIfHorVert {
        seenPoints[point, default: 0] += 1
      }
    }

    return seenPoints.values.filter { $0 > 1 }.count.description
  }

  func solve2() -> String {
    let lines = file.lines.map(Vector2D.init)

    let horVertLines = lines.filter(\.isHorVert)
    let diagonalLines = lines.filter(\.isDiagonal)

    var seenPoints: [Point2D: Int] = [:]

    for line in horVertLines {
      for point in line.allPointsIfHorVert {
        seenPoints[point, default: 0] += 1
      }
    }

    for line in diagonalLines {
      for point in line.allPointsIfDiagonal {
        seenPoints[point, default: 0] += 1
      }
    }

    return seenPoints.values.filter { $0 > 1 }.count.description
  }
}
