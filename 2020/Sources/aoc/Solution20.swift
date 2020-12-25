extension Collection where Self.Iterator.Element: RandomAccessCollection {
  func mirrored() -> [[Self.Iterator.Element.Iterator.Element]] {
    return self.map { $0.reversed() }
  }
}

class Solution20: Solving {
  typealias T = [[Character]]

  enum Orientation {
    case _0, _90, _180, _270, m0, m90, m180, m270
  }

  struct Tile {
    let id: Int
    let t: T
    lazy var top: Int = intFromBinary(t[0])
    lazy var bottom: Int = intFromBinary(t.last!)
    lazy var left: Int = intFromBinary(t.map { $0[0] })
    lazy var right: Int = intFromBinary(t.map { $0.last! })

    lazy var borders = [top, right, bottom, left]

    func intFromBinary(_ border: [Character]) -> Int {
      let binStr = String(border).replacingOccurrences(of: ".", with: "0").replacingOccurrences(of: "#", with: "1")
      return min(Int(binStr, radix: 2)!, Int(String(binStr.reversed()), radix: 2)!)
    }

    func transposed(or: Orientation) -> T {
      switch or {
      case ._0: return t
      case ._90: return rotate(t)
      case ._180: return rotate(rotate(t))
      case ._270: return rotate(rotate(rotate(t)))
      case .m0: return t.mirrored()
      case .m90: return rotate(t).mirrored()
      case .m180: return rotate(rotate(t)).mirrored()
      case .m270: return rotate(rotate(rotate(t))).mirrored()
      }
    }

    func rotate(_ t: T) -> T {
      var res: T = []
      for y in t.indices {
        res.append([])
        for x in t.indices {
          res[y].append(t[(t.count - 1)-x][y])
        }
      }
      return res
    }
  }

  let file: File
  var tiles: [Int: Tile] = [:]
  lazy var size = Int(Double(tiles.count).squareRoot())
  var allBorders: [Int: [Int]] = [:]

  required init(file: File) {
    self.file = file

    for block in file.linesSplitByEmptyLine {
      let id = Int(block[0].dropFirst(5).dropLast())!
      let t = block.dropFirst().map { (line: String) -> [Character] in
        Array(line)
      }
      var tile = Tile(id: id, t: t)
      tiles[id] = tile

      for border in tile.borders {
        allBorders[border, default: []].append(id)
      }
    }
  }

  func solve1() -> String {
    let tilesOnEdge = Set(allBorders.values.filter { $0.count == 1 }.flatMap { $0 })

    let tilesOnCorner = tilesOnEdge.filter { edgeID in
      allBorders.values.filter { $0 == [edgeID] }.count == 2
    }
    print("corner pieces: ", tilesOnCorner)

    return tilesOnCorner.reduce(1, *).description
  }

  var tilesOnEdge: Set<Int> = []
  var tilesOnCorner: Set<Int> = []
  var tilesInCenter: Set<Int> = []

  func solve2() -> String {
    tilesOnEdge = Set(allBorders.values.filter { $0.count == 1 }.flatMap { $0 })

    tilesOnCorner = tilesOnEdge.filter { edgeID in
      allBorders.values.filter { $0 == [edgeID] }.count == 2
    }

    tilesOnEdge.subtract(tilesOnCorner)
    tilesInCenter = Set(allBorders.values.flatMap { $0 }).subtracting(tilesOnEdge).subtracting(tilesOnCorner)

    // tile id, or, leftBorder, bottomBorder
    var tGrid: [[GridTile]] = []
    var grid: [[Character]] = Array(repeating: Array(repeating: ".", count: size * 8), count: size * 8)
    var gridWithBorders: [[Character]] = Array(repeating: Array(repeating: ".", count: size * 10), count: size * 10)
    for y in 0..<size {
      tGrid.append([])
      for x in 0..<size {
        // print(x, y)
        let t = getNextTile(x, y, tGrid)
        tGrid[y].append(t)
        print(t)
        grid = fill(t, to: grid, x: x, y: y)
        // printGrid(grid)
        gridWithBorders = fillWithBorders(t, to: gridWithBorders, x: x, y: y)
      }
    }
    printGrid(grid)


    // Then to find the monsters, take a sliding window approach, matching with the monster first horizontally (all 4 possible configs),
    // then vertically (4 again)
    return file.lines.joined(separator: "\n")
  }

  typealias GridTile = (id: Int, or: Orientation, right: Int, bottom: Int)

  func getNextTile(_ x: Int, _ y: Int, _ grid: [[GridTile]]) -> GridTile {
    switch(x, y) {
    case (0, 0): // top left
      return getGridTile(tilesOnCorner.removeFirst(), left: nil, top: nil)
    case (size - 1, 0): // top right
      let leftBorderTile = grid[y][x-1].right
      let selected = tilesOnCorner.first { tiles[$0]!.borders.contains(leftBorderTile) }!
      tilesOnCorner.remove(selected)
      return getGridTile(selected, left: leftBorderTile, top: nil)
    case (0, size - 1): // bottmo left
      let topBorderTile = grid[y-1][x].bottom
      let selected = tilesOnCorner.first { tiles[$0]!.borders.contains(topBorderTile) }!
      tilesOnCorner.remove(selected)
      return getGridTile(selected, left: nil, top: topBorderTile)
    case (size - 1, size - 1): // bottom right
      let leftBorderTile = grid[y][x-1].right
      let selected = tilesOnCorner.first { tiles[$0]!.borders.contains(leftBorderTile) }!
      tilesOnCorner.remove(selected)
      return getGridTile(selected, left: leftBorderTile, top: grid[y-1][x].bottom)
    case (1..., 0): // top row
      let leftBorderTile = grid[y][x-1].right
      let selected = tilesOnEdge.first { tiles[$0]!.borders.contains(leftBorderTile) }!
      tilesOnEdge.remove(selected)
      return getGridTile(selected, left: leftBorderTile, top: nil)
    case (1..., size - 1): // bottom row
      let leftBorderTile = grid[y][x-1].right
      let selected = tilesOnEdge.first { tiles[$0]!.borders.contains(leftBorderTile) }!
      tilesOnEdge.remove(selected)
      return getGridTile(selected, left: leftBorderTile, top: grid[y-1][x].bottom)
    case (0, 1...): //left col
      let topBorderTile = grid[y-1][x].bottom
      let selected = tilesOnEdge.first { tiles[$0]!.borders.contains(topBorderTile) }!
      tilesOnEdge.remove(selected)
      return getGridTile(selected, left: nil, top: topBorderTile)
    case (size - 1, 1...): //right col
      let topBorderTile = grid[y-1][x].bottom
      let selected = tilesOnEdge.first { tiles[$0]!.borders.contains(topBorderTile) }!
      tilesOnEdge.remove(selected)
      return getGridTile(selected, left: grid[y][x-1].right, top: topBorderTile)
    default: //center
      let topBorderTile = grid[y-1][x].bottom
      let selected = tilesInCenter.first { tiles[$0]!.borders.contains(topBorderTile) }!
      tilesInCenter.remove(selected)
      return getGridTile(selected, left: grid[y][x-1].right, top: topBorderTile)
    }
  }

  func getGridTile(_ t: Int, left: Int?, top: Int?) -> GridTile {
    var tile = tiles[t]!
    switch (left, top) {
    case (nil, nil): // top left corner
      var uniques: [Int] = []
      for (i, border) in tile.borders.enumerated() {
        if allBorders[border]!.count == 1 {
          uniques.append(i)
        }
      }
      switch (uniques[0], uniques[1]) {
      case (0, 1): // top and right are unique
        return (id: t, or: ._270, right: tile.bottom, bottom: tile.left)
      case (1, 2): // right and bottom are unique
        return (id: t, or: ._180, right: tile.left, bottom: tile.top)
      case (2, 3): // bottoom and left arer unique
        return (id: t, or: ._90, right: tile.top, bottom: tile.right)
      default:
        return (id: t, or: ._0, right: tile.right, bottom: tile.bottom)
      }
    case (let .some(l), nil): // top row
      let borders = tile.borders
      let leftIdx = borders.firstIndex(of: l)!
      let top = borders[(leftIdx + 1)%4]
      let isMirrored = allBorders[top]!.count != 1
      switch (leftIdx, isMirrored) {
      case (0, false): // left side is on top
        return (id: t, or: ._270, right: tile.bottom, bottom: tile.left)
      case (1, false): // left side is on right
        return (id: t, or: ._180, right: tile.left, bottom: tile.top)
      case (2, false): // left side is on bottom
        return (id: t, or: ._90, right: tile.top, bottom: tile.right)
      case (3, false): // left side is left
        return (id: t, or: ._0, right: tile.right, bottom: tile.bottom)
      case (0, true): // left side is on top
        return (id: t, or: .m270, right: tile.bottom, bottom: tile.right)
      case (1, true): // left side is on right
        return (id: t, or: .m180, right: tile.left, bottom: tile.bottom)
      case (2, true): // left side is on bottom
        return (id: t, or: .m90, right: tile.top, bottom: tile.left)
      case (3, true): // left side is left
        return (id: t, or: .m0, right: tile.right, bottom: tile.top)
      default: preconditionFailure("unexpected index: \(leftIdx)")
      }
    case (nil, let .some(top)): // left col
      let borders = tile.borders
      let topIdx = borders.firstIndex(of: top)!
      let left = borders[(topIdx + 3)%4]
      let isMirrored = allBorders[left]!.count != 1
      switch (topIdx, isMirrored) {
      case (0, false): // top side is on top
        return (id: t, or: ._0, right: tile.right, bottom: tile.bottom)
      case (1, false): // top side is on right
        return (id: t, or: ._270, right: tile.bottom, bottom: tile.left)
      case (2, false): // top  side is on bottom
        return (id: t, or: ._180, right: tile.left, bottom: tile.top)
      case (3, false): // top  side is left
        return (id: t, or: ._90, right: tile.top, bottom: tile.right)
      case (0, true): // top side is on top
        return (id: t, or: .m0, right: tile.left, bottom: tile.bottom)
      case (1, true): // top side is on right
        return (id: t, or: .m270, right: tile.top, bottom: tile.left)
      case (2, true): // top side is on bottom
        return (id: t, or: .m180, right: tile.right, bottom: tile.top)
      case (3, true): // top side is left
        return (id: t, or: .m90, right: tile.bottom, bottom: tile.right)
      default: preconditionFailure("unexpected index: \(topIdx)")
      }
    case (let .some(l), let .some(top)):
      let borders = tile.borders
      let topIdx = borders.firstIndex(of: top)!
      let left = borders[(topIdx + 3)%4]
      let isMirrored = left != l
      switch (topIdx, isMirrored) {
      case (0, false): // top side is on top
        return (id: t, or: ._0, right: tile.right, bottom: tile.bottom)
      case (1, false): // top side is on right
        return (id: t, or: ._270, right: tile.bottom, bottom: tile.left)
      case (2, false): // top  side is on bottom
        return (id: t, or: ._180, right: tile.left, bottom: tile.top)
      case (3, false): // top  side is left
        return (id: t, or: ._90, right: tile.top, bottom: tile.right)
      case (0, true): // top side is on top
        return (id: t, or: .m0, right: tile.left, bottom: tile.bottom)
      case (1, true): // top side is on right
        return (id: t, or: .m270, right: tile.top, bottom: tile.left)
      case (2, true): // top side is on bottom
        return (id: t, or: .m180, right: tile.right, bottom: tile.top)
      case (3, true): // top side is left
        return (id: t, or: .m90, right: tile.bottom, bottom: tile.right)
      default: preconditionFailure("unexpected index: \(topIdx)")
      }
    }
  }

  func fill(_ t: GridTile, to grid: T, x: Int, y: Int) -> T {
    var grid = grid
    let chars = tiles[t.id]!.transposed(or: t.or)

    for yy in 1...8 {
      for xx in 1...8 {
        grid[y*8+(yy - 1)][x*8+(xx - 1)] = chars[yy][xx]
      }
    }
    return grid
  }

    func fillWithBorders(_ t: GridTile, to grid: T, x: Int, y: Int) -> T {
    var grid = grid
    let chars = tiles[t.id]!.transposed(or: t.or)

    for yy in 0..<10 {
      for xx in 0..<10 {
        grid[y*10+yy][x*10+xx] = chars[yy][xx]
      }
    }
    return grid
  }

  func tilesDescr() -> String {
    var descr = ""
    for t in tiles {
      descr += "Tile \(t.key)\n"
      descr += "\n"
    }
    return descr
  }

  func printGrid(_ t: T) {
    for (_, line) in t.enumerated() {
      print(String(line))
    }
    print()
  }
}
