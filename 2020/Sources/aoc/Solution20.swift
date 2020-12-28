extension Array where Self.Iterator.Element: RandomAccessCollection, Self.Iterator.Element.Iterator.Element == Character {
  func mirrored() -> [[Self.Iterator.Element.Iterator.Element]] {
    return self.map { $0.reversed() }
  }

  func rotated() -> [[Self.Iterator.Element.Iterator.Element]] {
      var res: [[Self.Iterator.Element.Iterator.Element]] = []

      for y in self.first!.indices {
        var row: [Self.Iterator.Element.Iterator.Element] = []
        for x in indices {
          row.append(self[(count - 1)-x][y])
        }
        res.append(row)
      }
      return res
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
      case ._90: return t.rotated()
      case ._180: return t.rotated().rotated()
      case ._270: return t.rotated().rotated().rotated()
      case .m0: return t.mirrored()
      case .m90: return t.rotated().mirrored()
      case .m180: return t.rotated().rotated().mirrored()
      case .m270: return t.rotated().rotated().rotated().mirrored()
      }
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
  var grid: T = []

  func solve2() -> String {
    tilesOnEdge = Set(allBorders.values.filter { $0.count == 1 }.flatMap { $0 })

    tilesOnCorner = tilesOnEdge.filter { edgeID in
      allBorders.values.filter { $0 == [edgeID] }.count == 2
    }

    tilesOnEdge.subtract(tilesOnCorner)
    tilesInCenter = Set(allBorders.values.flatMap { $0 }).subtracting(tilesOnEdge).subtracting(tilesOnCorner)

    // tile id, or, leftBorder, bottomBorder
    var tGrid: [[GridTile]] = []
    grid = Array(repeating: Array(repeating: ".", count: size * 8), count: size * 8)
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
    // printGrid(grid)

    // print(pattern)
    let size = (x: 20, y: 3)

    let pLines = pattern.components(separatedBy: "\n").map { Array($0) }
    var allHorizontalPatterns = [pLines]
    allHorizontalPatterns.append(pLines.rotated().rotated()) // rotated twice
    allHorizontalPatterns.append(pLines.mirrored()) // hor mirror: .m0
    allHorizontalPatterns.append(pLines.rotated().rotated().mirrored()) // vertical mirror, .m180

    print("sep")
    printGrid(allHorizontalPatterns[0])
    print("sep")
    printGrid(allHorizontalPatterns[1])
    print("sep")
    printGrid(allHorizontalPatterns[3])
    print("sep")

    var allVerticalPatterns: [[[Character]]] = []
    allVerticalPatterns.append(pLines.rotated()) // .)90
    allVerticalPatterns.append(pLines.rotated().reversed()) // .m90
    allVerticalPatterns.append(pLines.rotated().rotated().rotated()) // ._270
    allVerticalPatterns.append(pLines.rotated().rotated().rotated().mirrored()) // .m270
    print(grid.count, grid[0].count)
    // .0    -> (2, 2) & (1, 16)
    // .m180 -> (2, 19)
    // ._270 -> (2, 2) & (16, 3)
    // ._180 -> (2, 19)
    var matches = 0
    for y in 0...(grid.count - size.y) {
      for x in 0...(grid[0].count - size.x) {
        for (pattern, or) in zip(allHorizontalPatterns, [Orientation._0, ._180, .m0, .m180]) {
          if match(pattern: pattern, x: x, y: y, width: size.x, height: size.y) {
            print("r: \(or): Hor matchFound: \(x), \(y)")
            matches += 1
          }
        }
      }
    }
    for y in 0...(grid.count - size.x) {
      for x in 0...(grid[0].count - size.y) {
        for (pattern, or) in zip(allVerticalPatterns, [Orientation._90, .m90, ._270, .m270]) {
          if match(pattern: pattern, x: x, y: y, width: size.y, height: size.x) {
            print("r: \(or): Ver matchFound: \(x), \(y)")
            // print(pattern.map { String($0) }.joined(separator: "\n"))
            matches += 1
          }
        }
      }
    }
    printGrid(grid)
    return matches.description
  }

  let pattern = "                  # \n#    ##    ##    ###\n #  #  #  #  #  #   "

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
    case (let .some(l), nil): // top row -> doesn't always work for toop right

      let borders = tile.borders
      let leftIdx = borders.firstIndex(of: l)!
      let top = borders[(leftIdx + 1)%4]
      print(borders)
      print(borders.map { allBorders[$0]!.count })
      let uniques = borders.filter { allBorders[$0]!.count == 1 }
      if uniques.count > 1 {
        // volgorde cw: l, unique, unique, b
        let uniqIndices = uniques.map { borders.firstIndex(of: $0)! }.sorted()
        if uniqIndices[0] + 1 == uniqIndices[1] { /*not mirrored*/ }

      }
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

  func match(pattern: T, x: Int, y: Int, width: Int, height: Int) -> Bool {
    let res = true

    for yy in 0..<height {
      for xx in 0..<width {
        let p = pattern[yy][xx]
        let g = grid[y + yy][x + xx]
        if p == "#" && !(g == "#" || g == "O") {
          return false
        }
      }
    }
    for yy in 0..<height {
      for xx in 0..<width {
        let p = pattern[yy][xx]
        if p == "#" {
          grid[y + yy][x + xx] = "O"
        }
      }
    }
    return res
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
