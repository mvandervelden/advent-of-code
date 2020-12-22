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

  struct Tile {
    let id: Int
    let t: T

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
      let tile = Tile(id: id, t: t)
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
      descr += "Tile \(t.key)\n"
      descr += "\n"
    }
    return descr
  }
}
