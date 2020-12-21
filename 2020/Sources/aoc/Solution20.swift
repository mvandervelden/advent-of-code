extension Collection where Self.Iterator.Element: RandomAccessCollection {
  func transposed() -> [[Self.Iterator.Element.Iterator.Element]] {
    guard let firstRow = self.first else { return [] }
    return firstRow.indices.map { index in
      self.map{ $0[index] }
    }
  }
}

class Solution20: Solving {
  typealias T = [[Character]]

  enum Rot: CaseIterable {
    case _0, _90, _180, _270
  }

  enum Side {
    case top, bottom, left, right
  }

  struct Orientation: Hashable {
    let isHorMirrored: Bool
    let isVerMirrored: Bool
    let rotation: Rot

    static var normal: Self {
      return Orientation(isHorMirrored: false, isVerMirrored: false, rotation: ._0)
    }

    func orient(t: T) -> T {
      return verMirror(t: horMirror(t: rotate(t: t)))
    }

    func rotate(t: T) -> T {
      switch rotation {
      case ._0: return t
      case ._90: return t.transposed()
      case ._180: return t.transposed().transposed()
      case ._270: return t.transposed().transposed().transposed()
      }
    }

    func horMirror(t: T) -> T {
      guard isHorMirrored else { return t }

      return t.map { $0.reversed() }
    }

    func verMirror(t: T) -> T {
      guard isVerMirrored else { return t }

      return t.reversed()
    }
  }

  struct Grid: Hashable, CustomStringConvertible, CustomDebugStringConvertible {
    let g: [[Tile]]
    let undecided: [Tile]
    let side: Int

    var isGoal: Bool { undecided.isEmpty }

    var nextIdx: (x: Int, y: Int) {
      let linIdx = side * side - undecided.count
      return (x: linIdx % side, y: linIdx / side)
    }

    var debugDescription: String {
      return "Grid: tiles laid: \(g.reduce(0) { $0 + $1.count }), undecided: \(undecided.count)"
    }

    var cornerProduct: Int {
      return g[0][0].id * g.last![0].id * g[0].last!.id * g.last!.last!.id
    }

    var description: String {
      var descr = ""
      for row in g {
        let tiles = row.map(\.orientedTile)
        for i in 0..<tiles[0].count {
          descr += tiles.map { String($0[i]) }.joined(separator: " ")
          descr += "\n"
        }
        descr += "\n"
      }
      return descr
    }

    var possibleNextGrids: [Grid] {
      switch nextIdx {
      case (0, 0):
        return undecided.flatMap { (u: Tile) -> [Grid] in
          var newUndecided = undecided
          newUndecided.removeAll { $0 == u }
          return u.allOrientations.map { t in
            Grid(g: [[t]], undecided: newUndecided, side: side)
          }
        }
      case (let x, 0):
        return undecided.flatMap { (u: Tile) -> [Grid] in
          var newUndecided = undecided
          newUndecided.removeAll { $0 == u }
          return u.allOrientations.filter {
            g[0][x-1].fits($0, on: .right)
          }.map { t in
            var newG = g
            newG[0] = g[0] + [t]
            return Grid(g: newG, undecided: newUndecided, side: side)
          }
        }
      case (0, let y):
        return undecided.flatMap { (u: Tile) -> [Grid] in
          var newUndecided = undecided
          newUndecided.removeAll { $0 == u }
          return u.allOrientations.filter {
            g[y-1][0].fits($0, on: .bottom)
          }.map { t in
            var newG = g
            newG.append([t])
            return Grid(g: newG, undecided: newUndecided, side: side)
          }
        }
      case (let x, let y):
        return undecided.flatMap { (u: Tile) -> [Grid] in
          var newUndecided = undecided
          newUndecided.removeAll { $0 == u }
          return u.allOrientations.filter {
            g[y][x-1].fits($0, on: .right) && g[y-1][x].fits($0, on: .bottom)
          }.map { t in
            var newG = g
            newG[y] = g[y] + [t]
            return Grid(g: newG, undecided: newUndecided, side: side)
          }
        }
      }
    }
  }

  struct Tile: Hashable {
    let id: Int
    let t: T
    let or: Orientation

    var orientedTile: T {
      return or.orient(t: t)
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
      hasher.combine(or)
    }

    func fits(_ other: Tile, on side: Side) -> Bool {
      switch side {
      case .top:
        return orientedTile.first == other.orientedTile.last
      case .bottom:
        return orientedTile.last == other.orientedTile.first
      case .left:
        return orientedTile.compactMap(\.first) == other.orientedTile.compactMap(\.last)
      case .right:
        return orientedTile.compactMap(\.last) == other.orientedTile.compactMap(\.first)
      }
    }

    func orientated(_ or: Orientation) -> Tile {
      return Tile(id: id, t: t, or: or)
    }

    var allOrientations: [Tile] {
      return [false, true].flatMap { hor in
        [false, true].flatMap { ver in
          Rot.allCases.map { rot in
            return Tile(id: id, t: t, or: Orientation(isHorMirrored: hor, isVerMirrored: ver, rotation: rot))
          }
        }
      }
    }

    static var placeholder: Self {
      return Tile(id: -1, t: [], or: .normal)
    }
  }

  let file: File
  let tiles: [Tile]
  lazy var size = Int(Double(tiles.count).squareRoot())
  var potentialSides: [[[Character]]] = []

  required init(file: File) {
    self.file = file
    tiles = file.linesSplitByEmptyLine.map { block in
      let id = Int(block[0].dropFirst(5).dropLast())!
      let t = block.dropFirst().map { (line: String) -> [Character] in
        Array(line)
      }
      return Tile(id: id, t: t, or: .normal)
    }

    for tile in tiles {
      var tileSides: [[Character]] = []
      tileSides.append(tile.t[0])
      tileSides.append(tile.t[0].reversed())
      tileSides.append(tile.t.last!)
      tileSides.append(tile.t.last!.reversed())
      let col0 = tile.t.map { $0[0] }
      tileSides.append(col0)
      tileSides.append(col0.reversed())
      let colLast = tile.t.map { $0.last! }
      tileSides.append(colLast)
      tileSides.append(colLast.reversed())
      potentialSides.append(tileSides)
    }
  }

  func solve1() -> String {
    let start = Grid(g: [], undecided: tiles, side: size)
    let path = astar(start: start)
    print(path!.first!.description)
    return path!.first!.cornerProduct.description
  }

  func solve2() -> String {
    return file.lines.joined(separator: "\n")
  }

  func astar(start: Grid) -> [Grid]? {
    var closedSet: Set<Grid> = []
    var openSet: Set<Grid> = [start]
    var cameFrom: [Grid: Grid] = [:]
    var gScore: [Grid: Int] = [start: 0]
    var fScore: [Grid: Int] = [start: heuristicEstimate(start: start)]

    while !openSet.isEmpty {
      // print("openSet", openSet)
      // print("closedSet", closedSet)
      // print("cameFrom", cameFrom)
      // print("gScore", gScore)
      // print("fScore", fScore)
      // print("finding current")
      let current = openSet.min {
        let lhsScore = fScore[$0] ?? Int.max
        let rhsScore = fScore[$1] ?? Int.max
        return lhsScore < rhsScore //|| (lhsScore == rhsScore && ($0.y < $1.y || ($0.y == $1.y && $0.x < $1.x)))
      }!
      // let current = openSet.min { fScore[$0] ?? Int.max < fScore[$1] ?? Int.max }!
      // print("current", current, fScore[current]!)
      // if fScore[current]! > 45 {
      //     print("openSet", openSet)
      //     print("closedSet", closedSet)
      //     print("cameFrom", cameFrom)
      //     print("gScore", gScore)
      //     print("fScore", fScore)
      //     fatalError()
      // }
      if current.isGoal {
        print("total cost: ", gScore[current]!)
        return reconstruct(cameFrom, current: current)
      }

      openSet.remove(current)
      closedSet.insert(current)

      for neighbor in neighbors(current) {
        // print("neighbor", neighbor)
        if closedSet.contains(neighbor.loc) {
          continue
        }

        let tentativeG = gScore[current]! + neighbor.cost// + 1000000 + neighbor.y * 100 + neighbor.x

        if !openSet.contains(neighbor.loc) {
          openSet.insert(neighbor.loc)
        } else if tentativeG >= gScore[neighbor.loc] ?? Int.max {
          continue
        }
        // print("Adding neighbor")
        cameFrom[neighbor.loc] = current
        gScore[neighbor.loc] = tentativeG
        fScore[neighbor.loc] = tentativeG + heuristicEstimate(start: neighbor.loc)
        // print("Added neighbor")
      }
    }

    return nil
  }

  func heuristicEstimate(start: Grid) -> Int {
    return start.undecided.count
  }

  func reconstruct(_ cameFrom: [Grid: Grid], current: Grid) -> [Grid] {
    var current = current
    var totalPath = [current]
    while cameFrom[current] != nil {
      current = cameFrom[current]!
      totalPath.append(current)
    }
    return totalPath
  }

  func neighbors(_ loc: Grid) -> [(loc: Grid, cost: Int)] {
    return loc.possibleNextGrids.map { (loc: $0, cost: 1)}
  }

  func tilesDescr() -> String {
    var descr = ""
    for t in tiles {
      descr += "Tile \(t.id)\n"
      for line in t.orientedTile {
        descr += String(line) + "\n"
      }
      descr += "\n"
    }
    return descr
  }
}
