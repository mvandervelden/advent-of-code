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

    var borders: [[Character]] {
      var tileSides: [[Character]] = []
      tileSides.append(t[0])
      tileSides.append(t[0].reversed())
      tileSides.append(t.last!)
      tileSides.append(t.last!.reversed())
      let col0 = t.map { $0[0] }
      tileSides.append(col0)
      tileSides.append(col0.reversed())
      let colLast = t.map { $0.last! }
      tileSides.append(colLast)
      tileSides.append(colLast.reversed())
      return tileSides
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
  var tiles: [Int: Tile] = [:]
  lazy var size = Int(Double(tiles.count).squareRoot())
  var allBorders: [[Character]: [Int]] = [:]

  required init(file: File) {
    self.file = file

    for block in file.linesSplitByEmptyLine {
      let id = Int(block[0].dropFirst(5).dropLast())!
      let t = block.dropFirst().map { (line: String) -> [Character] in
        Array(line)
      }
      let tile = Tile(id: id, t: t, or: .normal)
      tiles[id] = tile

      for border in tile.borders {
        allBorders[border, default: []].append(id)
      }
    }
  }

  func solve1() -> String {
    let tilesOnEdge = Set(allBorders.values.filter { $0.count == 1 }.flatMap { $0 })

    let tilesOnCorner = tilesOnEdge.filter { edgeID in
      allBorders.values.filter { $0 == [edgeID] }.count == 4 // 4, becausee the reverse edges are also in there
    }
    print("corner pieces: ", tilesOnCorner)

    return tilesOnCorner.reduce(1, *).description
  }

  func solve2() -> String {
    return file.lines.joined(separator: "\n")
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
