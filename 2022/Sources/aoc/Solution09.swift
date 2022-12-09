class Solution09: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let grid = simulate(length: 2)
    return grid.count.description
  }

  func solve2() -> String {
    let grid = simulate(length: 10)
    return grid.count.description
  }

  private func simulate(length: Int) -> Grid {
    var rope = Array(repeating: Point2D(x: 0, y: 0), count: length)
    var tLocs = Grid()
    tLocs.add(rope.last!)

    file.words.forEach { line in
      let count = Int(line[1])!
      let direction = line[0]
      // print(line)
      for _ in 0..<count {
        rope[0] = rope[0].move(direction)

        var didMove = true

        for i in 1..<length {
          if didMove == false { break }

          if !rope[i].isAdjacentTo(rope[i-1]) {
            rope[i] = rope[i].follow(rope[i-1])
          } else {
            didMove = false
          }
        }
        tLocs.add(rope.last!)
      }
      // print(tLocs)
      // printRope(rope)
    }
    // print(tLocs)
    // printRope(rope)
    return tLocs
  }

  func printRope(_ rope: [Point2D]) {
    let minX = ([0] + rope.map(\.x)).min() ?? 0
    let maxX = ([0] + rope.map(\.x)).max() ?? 0
    let minY = ([0] + rope.map(\.y)).min() ?? 0
    let maxY = ([0] + rope.map(\.y)).max() ?? 0

    let string = (minY...maxY).map { y in
      (minX...maxX).map { x in
        if let match = rope.enumerated().first(where: { $0.element.x == x && $0.element.y == y }) {
          return "\(match.offset)"
        }

        return "."
      }.joined()
    }.joined(separator: "\n")

    print(string)
    print()
  }
}

extension Point2D {
  func move(_ dir: String) -> Point2D {
    switch dir {
    case "U": return up(1)
    case "D": return down(1)
    case "L": return left(1)
    case "R": return right(1)
    default: fatalError()
    }
  }

  func follow(_ other: Point2D) -> Point2D {
    if abs(x - other.x) <= 1 && abs(y - other.y) <= 1 { return self }

    let stepX = min(max(other.x - x, -1), 1)
    let stepY = min(max(other.y - y, -1), 1)

    return Point2D(x: x + stepX, y: y + stepY)
  }
}

struct Grid: CustomStringConvertible {
  private var grid: [Int: Set<Int>] = [:]

  var minX: Int { grid.keys.min() ?? 0 }
  var maxX: Int { grid.keys.max() ?? 0 }
  var minY: Int { grid.values.compactMap { $0.min() }.min() ?? 0 }
  var maxY: Int { grid.values.compactMap{ $0.max() }.max() ?? 0 }

  mutating func add(_ point: Point2D) {
    grid[point.x, default: []].insert(point.y)
  }

  var description: String {
    (minY...maxY).map { y in
      (minX...maxX).map { x in
        if let col = grid[x], col.contains(y) { return "#" }
        return "."
      }.joined()
    }.joined(separator: "\n")
  }

  var count: Int {
    grid.values.map { $0.count }.sum()
  }
}
