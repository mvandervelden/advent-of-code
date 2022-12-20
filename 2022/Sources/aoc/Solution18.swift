class Solution18: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let points = file.csv.map { Point3D(x: Int($0[0])!, y: Int($0[1])!, z: Int($0[2])!) }
    let surfaceArea = surfaceArea(points)

    return surfaceArea.description
  }

  func surfaceArea(_ points: [Point3D]) -> Int {
    var surfaceArea = 0

    for (i, pointI) in points.enumerated() {
      var neighbors = 0
      for (j, pointJ) in points.enumerated() where i != j {
        if pointI.isAdjacent(to: pointJ) { neighbors += 1 }
      }
      surfaceArea += 6 - neighbors
    }

    return surfaceArea
  }

  func solve2() -> String {
    var points = file.csv.map { Point3D(x: Int($0[0])!, y: Int($0[1])!, z: Int($0[2])!) }
    let minX = points.map(\.x).min()!
    let maxX = points.map(\.x).max()!
    let minY = points.map(\.y).min()!
    let maxY = points.map(\.y).max()!
    let minZ = points.map(\.z).min()!
    let maxZ = points.map(\.z).max()!

    var grid: [[[Int]]] = Array(repeating: Array(repeating: Array(repeating: 0, count: maxX-minX+1), count: maxY-minY+1), count: maxZ-minZ+1)

    for point in points {
      grid[point.z-minZ][point.y-minY][point.x-minX] = 1
    }

    // print(grid.prettyDescription)
    // print(points)

    for _ in 0...10 {
      for x in minX...maxX {
        for y in minY...maxY {
          for z in minZ...maxZ {

            if grid[z-minZ][y-minY][x-minX] == 0 {
              let point = Point3D(x: x-minX, y: y-minY, z: z-minZ)
              let neighbors = point.neighbors(maxX: maxX-minX, maxY: maxY-minY, maxZ: maxZ-minZ)
              if neighbors.count < 6 {
                // print("edgeFound", point)
                grid[point.z][point.y][point.x] = 9
              } else if let _ = neighbors.first(where: { grid[$0.z][$0.y][$0.x] == 9 }) {
                // print("reachesEdgeFound", point)
                grid[point.z][point.y][point.x] = 9
              } else if neighbors.allSatisfy({ grid[$0.z][$0.y][$0.x] == 1 }) {
                // print("pocketFound", point)
                grid[point.z][point.y][point.x] = 1
                points.append(Point3D(x: x, y: y, z: z))
              }
            }
          }
        }
      }
    }

    for (z, i) in grid.enumerated() {
      for (y, j) in i.enumerated() {
        for (x, k) in j.enumerated() {
          if k == 0 {
            grid[z][y][x] = 5
            points.append(Point3D(x: minX+x, y: y+minY, z: z+minZ))
          }
        }
      }
    }
    // print(grid.prettyDescription)
    // print(points)
    return surfaceArea(points).description
  }
}

extension Array where Element == [[Int]] {
  var prettyDescription: String {
    enumerated().map {  "z:\($0.0)\n\($0.1.prettyDescription)"}.joined(separator: "\n")
  }
}

extension Array where Element == [Int] {
  var prettyDescription: String {
    map { $0.prettyDescription }.joined(separator: "\n")
  }
}

extension Array where Element == Int {
  var prettyDescription: String {
    map { String($0) }.joined()
  }
}
