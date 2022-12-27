import SwiftGraph

class Solution24: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  var tGrid: [[[Character]]] = []

  func solve1() -> String {
    let grid = file.charsByLine
    print("creating state grid")
    create3DGrid(grid)

    var points: [[Point3D]] = []

    print("creating graph:")
    print(" creating potential states")
    for t in 0..<tGrid.count {
      var pList: [Point3D] = []
      for y in 0..<tGrid[0].count {
        for x in 0..<tGrid[0][0].count {
          if tGrid[t][y][x] == "." {
            pList.append(Point3D(x: x, y: y, z: t))
          }
        }
      }
      points.append(pList)
    }

    let indexOffsets = points.map(\.count)
    let allPoints = points.flatMap { $0 }
    let graph = UnweightedGraph<Point3D>(vertices: allPoints)

    print(" creating edges")
    for (t, pList) in points[..<(points.count - 1)].enumerated() {
      let compareList = points[t+1]
      print("  ", t)
      for (i, p1) in pList.enumerated() {
        for (j, p2) in compareList.enumerated() {
          if areAdjacent(p1, p2) {
            let offset1 = i + indexOffsets[..<t].sum()
            let offset2 = j + indexOffsets[...t].sum()
            // print("adding edge", p1, p2, "(i->j)", i, j, offset1, offset2, allPoints[offset1], allPoints[offset2])
            graph.addEdge(fromIndex: offset1 , toIndex: offset2, directed: true)
          }
        }
      }
    }

    print("start bfs")
    let path = graph.bfs(fromIndex: 0, goalTest: { $0.y == grid.count - 1 })

    // for p in (path.map(\.u) + [path.last!.v]) {
      // let pp = points[p]
      // print(pp)
      // var t = tGrid[pp.z]
      // if t[pp.y][pp.x] != "." { print("ERROR, overriding", t[pp.y][pp.x])}
      // t[pp.y][pp.x] = "E"
      // print(t.map { String($0) }.joined(separator: "\n"))
    // }

    // print(path)

    return path.count.description
  }

  func solve2() -> String {
    return file.filename
  }

  private func areAdjacent(_ p1: Point3D, _ p2: Point3D) -> Bool {
    // possible moves: t+1, x±1, y±i
    // assuming p2 always is the later one
    return p2.z == p1.z + 1 && Point2D(x: p1.x, y: p1.y).manhattanDist(to: Point2D(x: p2.x, y: p2.y)) <= 1
  }

  private func create3DGrid(_ initial: [[Character]]) {
    let width = initial[0].count
    let height = initial.count


    let xMax = width - 2
    let xMin = 1
    let yMax = height - 2
    let yMin = 1

    var current = initial
    tGrid.append(current)

    let tMax = min(500, (initial.count - 2) * (initial[0].count - 2))

    var upBlizzards: [Point2D] = []
    var downBlizzards: [Point2D] = []
    var rightBlizzards: [Point2D] = []
    var leftBlizzards: [Point2D] = []

    for (y, row) in current.enumerated() {
      for (x, ch) in row.enumerated() {
        switch ch {
        case "^": upBlizzards.append(Point2D(x: x, y: y))
        case "v": downBlizzards.append(Point2D(x: x, y: y))
        case ">": rightBlizzards.append(Point2D(x: x, y: y))
        case "<": leftBlizzards.append(Point2D(x: x, y: y))
        default: break
        }
      }
    }

    for t in 0..<tMax {
      var next = emptyGrid(width: width, height: height)

      var newUpBlizzards: [Point2D] = []
      for b in upBlizzards {
        let newX = b.x
        let newY = b.y > yMin ? b.y - 1 : yMax
        let newB = Point2D(x: newX, y: newY)
        if next[newB.y][newB.x] == "." {
          next[newB.y][newB.x] = "^"
        } else if let int = Int(String(next[newB.y][newB.x])) {
          next[newB.y][newB.x] = Character(String(int + 1))
        } else {
          next[newB.y][newB.x] = "2"
        }
        newUpBlizzards.append(newB)
      }
      var newDownBlizzards: [Point2D] = []
      for b in downBlizzards {
        let newX = b.x
        let newY = b.y < yMax ? b.y + 1 : yMin
        let newB = Point2D(x: newX, y: newY)
        if next[newB.y][newB.x] == "." {
          next[newB.y][newB.x] = "v"
        } else if let int = Int(String(next[newB.y][newB.x])) {
          next[newB.y][newB.x] = Character(String(int + 1))
        } else {
          next[newB.y][newB.x] = "2"
        }
        newDownBlizzards.append(newB)
      }
      var newRightBlizzards: [Point2D] = []
      for b in rightBlizzards {
        let newX = b.x < xMax ? b.x + 1 : xMin
        let newY = b.y
        let newB = Point2D(x: newX, y: newY)
        if next[newB.y][newB.x] == "." {
          next[newB.y][newB.x] = ">"
        } else if let int = Int(String(next[newB.y][newB.x])) {
          next[newB.y][newB.x] = Character(String(int + 1))
        } else {
          next[newB.y][newB.x] = "2"
        }
        newRightBlizzards.append(newB)
      }
      var newLeftBlizzards: [Point2D] = []
      for b in leftBlizzards {
        let newX = b.x > yMin ? b.x - 1 : xMax
        let newY = b.y
        let newB = Point2D(x: newX, y: newY)
        if next[newB.y][newB.x] == "." {
          next[newB.y][newB.x] = "<"
        } else if let int = Int(String(next[newB.y][newB.x])) {
          next[newB.y][newB.x] = Character(String(int + 1))
        } else {
          next[newB.y][newB.x] = "2"
        }
        newLeftBlizzards.append(newB)
      }

      upBlizzards = newUpBlizzards
      downBlizzards = newDownBlizzards
      rightBlizzards = newRightBlizzards
      leftBlizzards = newLeftBlizzards

      current = next
      tGrid.append(current)
    }
  }

  func emptyGrid(width: Int, height: Int) -> [[Character]] {
    let line: [Character] = ["#"] + Array(repeating: ".", count: width - 2) + ["#"]
    let topBottom: [Character] = Array(repeating: "#", count: width)
    var top = topBottom
    top[1] = "."
    var bottom = topBottom
    bottom[bottom.count-2] = "."
    return [top] + Array(repeating: line, count: height - 2) + [bottom]
  }
}

