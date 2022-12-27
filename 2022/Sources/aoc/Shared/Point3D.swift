struct Point3D: Hashable, CustomStringConvertible, Codable {
  struct Diff: Hashable, CustomStringConvertible {
    let dx: Int
    let dy: Int
    let dz: Int

    var description: String { "[\(dx),\(dy),\(dz)]" }

    static func == (lhs: Diff, rhs: Diff) -> Bool {
      if lhs.dx == rhs.dx && lhs.dy == rhs.dy && lhs.dz == rhs.dz { return true }
      if lhs.dx == rhs.dx && lhs.dy == rhs.dz && lhs.dz == rhs.dy { return true }
      if lhs.dx == rhs.dy && lhs.dy == rhs.dx && lhs.dz == rhs.dz { return true }
      if lhs.dx == rhs.dy && lhs.dy == rhs.dz && lhs.dz == rhs.dx { return true }
      if lhs.dx == rhs.dz && lhs.dy == rhs.dx && lhs.dz == rhs.dy { return true }
      if lhs.dx == rhs.dz && lhs.dy == rhs.dy && lhs.dz == rhs.dx { return true }
      return false
    }
  }

  let x: Int
  let y: Int
  let z: Int

  init(x: Int, y: Int, z: Int) {
    self.x = x
    self.y = y
    self.z = z
  }

  init(string: String) {
    let parts = string.split(separator: ",").map { Int($0)! }
    x = parts[0]
    y = parts[1]
    z = parts[2]
  }

  var description: String { "(\(x),\(y),\(z))" }

  func diff(_ other: Point3D) -> Diff {
    return Diff(dx: abs(x - other.x), dy: abs(y - other.y), dz: abs(z - other.z))
  }

  func relDiff(_ other: Point3D) -> Diff {
    return Diff(dx: x - other.x, dy: y - other.y, dz: z - other.z)
  }

  func manhattanDist(_ other: Point3D) -> Int {
    return abs(x - other.x) + abs(y - other.y) + abs(z - other.z)
  }

  func isAdjacent(to other: Point3D) -> Bool {
    return manhattanDist(other) == 1
  }

  func neighbors(maxX: Int, maxY: Int, maxZ: Int) -> [Point3D] {
    let xMin = max(x - 1, 0)
    let yMin = max(y - 1, 0)
    let zMin = max(z - 1, 0)
    let xMax = min(x + 1, maxX)
    let yMax = min(y + 1, maxY)
    let zMax = min(z + 1, maxZ)

    var neighbors: [Point3D] = []

    for xx in xMin...xMax {
      for yy in yMin...yMax {
        for zz in zMin...zMax {
          if [xx == x, yy == y, zz == z].filter({$0}).count == 2 {
            neighbors.append(Point3D(x: xx, y: yy, z: zz))
          }
        }
      }
    }

    return neighbors
  }
}
