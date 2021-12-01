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
    print(t.map { String($0) }.joined(separator: "\n"))
  }
}


// Stolen code:

class Day20 {
	var allTiles = [Int:Image](minimumCapacity: 150)
	var allBorders = [[Character]:[Int]](minimumCapacity: 150 * 8)

	// the number of Tiles that make up *one* edge of the full image
	// (e.g. for an input of 144 tiles, each edge would be 12 tiles long)
	var imageEdgeTileCount = 0

	struct Image: CustomStringConvertible {
		var id: Int
		var data: [[Character]]

		var rows: Int { data.count }
		var columns: Int { data[0].count }

		var borderTop: [Character] { data.first! }
		var borderBottom: [Character] { data.last! }
		var borderRight: [Character] { self.column(self.columns - 1) }
		var borderLeft: [Character] { self.column(0) }

		var borders: [[Character]] {
			[
				borderTop,
				borderBottom,
				borderLeft,
				borderRight,
				borderTop.reversed(),
				borderBottom.reversed(),
				borderLeft.reversed(),
				borderRight.reversed(),
			]
		}

		func column(_ column: Int) -> [Character] {
			self.data.map { $0[column] }
		}

		mutating func rotateRight() {
			self.data = (0..<self.columns).map { self.column($0).reversed() }
		}

		mutating func flip() {
			self.data.reverse()
		}

		mutating func cutBorders() {
			data.removeFirst()
			data.removeLast()

			for row in 0..<data.count {
				data[row].removeFirst()
				data[row].removeLast()
			}
		}

		var hashCount: Int {
			self.data.flatMap { $0 }.filter { $0 == "#" }.count
		}

		var description: String {
			let s = (data.map { String($0) }).joined(separator: "\n")
			return s
		}

		struct OrientationSequence: Sequence {
			let image: Image

			func makeIterator() -> OrientationIterator {
				return OrientationIterator(image: image)
			}
		}

		struct OrientationIterator: IteratorProtocol {
			var image: Image
			var iterCount = 0

			mutating func next() -> Image? {
				defer { iterCount += 1 }
				guard iterCount > 0 else { return image }
				guard iterCount < 8 else { return nil }

				if iterCount == 4 {
					image.flip()
				}

				image.rotateRight()
				return image
			}
		}
	}

	func findCornerPieceIds() -> Set<Int> {
		// besides finding corner pieces in the process, do a quick sanity check on our input.
		// - all borders must have exactly 1 or 2 corresponding pieces
		let invalidBorders = allBorders.values.filter { ![1,2].contains($0.count) }
		assert(invalidBorders.isEmpty, "some borders don't belong to exactly 1 or 2 pieces: \(invalidBorders)")

		// - exactly (imageEdgeTileCount * 4 - 4) pieces each have at least one unique border (edge pieces)
		let edgePieceIdsWithDuplicates = allBorders.values.filter { $0.count == 1 }.flatMap { $0 }
		let edgePieceIds = Set(edgePieceIdsWithDuplicates)
		assert(
			edgePieceIds.count == imageEdgeTileCount * 4 - 4,
			"expected \(imageEdgeTileCount * 4 - 4) edge pieces but found \(edgePieceIds.count)"
		)

		// - four of those images each have two unique borders (corner pieces)
		// note that for counting corner pieces (two unique borders), we search for edge pieces that have *four*
		// unique borders! this is because allBorders also includes the reversed version of each // border, s
		let cornerPieceIds = edgePieceIds.filter { epId in allBorders.values.filter { $0 == [epId] }.count == 4 }
		assert(cornerPieceIds.count == 4, "found \(cornerPieceIds.count) corner pieces instead of 4")

		print("edge pieces: \(edgePieceIds)")
		print("corner pieces: \(cornerPieceIds)")

		return cornerPieceIds
	}

	func assembleImage() -> Image {
		var imageTiles = [[Image]]()

		// start with any corner piece
		// n.b.: the first! of a Dictionary will be *undefined* and therefore
		// pseudo-random, which can have huge difference on the run time (on
		// how often the image/pattern in part 2 needs to be rotated and scanned).
		var topLeft = allTiles[findCornerPieceIds().first!]!

		// rotate it so it's the top-left corner
		for t in Image.OrientationSequence(image: topLeft) {
			let topIsUnique = allBorders[t.borderTop]! == [t.id]
			let leftIsUnique = allBorders[t.borderLeft]! == [t.id]
			guard !topIsUnique || !leftIsUnique else {
				topLeft = t
				break
			}
		}

		var tileRow = [Image]()
		tileRow += [topLeft]

		// now attach the other pieces
		while imageTiles.count < imageEdgeTileCount {
			let isFirstInRow = tileRow.isEmpty
			let tileToMatch = isFirstInRow ? imageTiles.last![0] : tileRow.last!
			let borderToMatch = isFirstInRow ? tileToMatch.borderBottom : tileToMatch.borderRight

			let nextTileIdList = allBorders[borderToMatch]!.filter { $0 != tileToMatch.id }
			assert(nextTileIdList.count == 1, "ambiguous next border after \(imageTiles.flatMap { $0 }.map { $0.id })")
			let nextTileId = nextTileIdList.first!

			for t in Image.OrientationSequence(image: allTiles[nextTileId]!) {
				let otherBorderToMatch = isFirstInRow ? t.borderTop : t.borderLeft
				if borderToMatch == otherBorderToMatch {
					tileRow += [t]
					break
				}
			}

			if tileRow.count == imageEdgeTileCount {
				imageTiles += [tileRow]
				tileRow.removeAll(keepingCapacity: true)
			}
		}

		print("imageTiles complete! \(imageTiles.flatMap { $0 }.map { $0.id })")

		// now just cut all the borders ...
		for tileRow in 0..<imageTiles.count {
			for tile in 0..<imageTiles[0].count {
				imageTiles[tileRow][tile].cutBorders()
			}
		}

		// ... and glue everything together ...
		var imageData = [[Character]]()
		imageData.reserveCapacity(200)
		for tileRow in imageTiles {
			for row in 0..<tileRow[0].data.count {
				var imageRow = [Character]()
				imageRow.reserveCapacity(200)
				for tile in tileRow {
					imageRow += tile.data[row]
				}
				imageData += [imageRow]
			}
		}

		// ... to create a new Image
		return Image(id: 0, data: imageData)

	}

	func part1(_ input: File) -> String {
		parse(input)

		imageEdgeTileCount = Int(Float(allTiles.count).squareRoot())
		print("image size \(imageEdgeTileCount)")

		return findCornerPieceIds().reduce(1, *).description
	}

	func part2(_ input: File) -> String {
		parse(input)

		imageEdgeTileCount = Int(Float(allTiles.count).squareRoot())
		print("image size \(imageEdgeTileCount)")

		let image = assembleImage()
		print("\(image)")

		let nemoPattern = [
			Array("                  # "),
			Array("#    ##    ##    ###"),
			Array(" #  #  #  #  #  #   "),
		]
		let nemo = Image(id: -1, data: nemoPattern)

		for nemoOrientation in Image.OrientationSequence(image: nemo) {
			let nemoCount = findNemo(in: image, usingPattern: nemoOrientation)
			if nemoCount > 0 {
				print("GOTCHA!")
				return (image.hashCount - nemo.hashCount * nemoCount).description
			}
		}

		preconditionFailure("no monsters here. apparently, that's a bad thing.")
	}

	func findNemo(in image: Image, usingPattern patternImage: Image) -> Int {
		let pattern = patternImage.data
		let patternHashCount = patternImage.hashCount
		var debugImage = image

		var found = 0
		for imageRow in 0..<(image.data.count - pattern.count) {
			for imageColumn in 0..<(image.data[0].count - pattern[0].count) {
				var hashCount = 0
				var debugImageTry = debugImage
				for patternRow in 0..<pattern.count {
					for patternColumn in 0..<pattern[0].count where pattern[patternRow][patternColumn] == "#" {
						if image.data[imageRow + patternRow][imageColumn + patternColumn] == "#" {
							hashCount += 1
							#if DEBUG
							debugImageTry.data[imageRow + patternRow][imageColumn + patternColumn] = "O"
							#endif
						}
					}
				}

				if hashCount == patternHashCount {
					print("Nemo found! Nemo (0,0) at image (\(imageColumn), \(imageRow))")
					found += 1
					debugImage = debugImageTry
				}
			}
		}

		if found > 0 {
			print(debugImage)
		}
		return found
	}

	func parse(_ input: File) {
		for lg in input.linesSplitByEmptyLine {
			var id = 0
			var data = [[Character]]()
			for line in lg {
				if line.hasPrefix("Tile ") {
					var parts = line.components(separatedBy: " ")
					parts[1].removeLast() // ":"
					id = Int(parts[1])!
					continue
				}

				data += [Array(line)]
			}

			let tile = Image(id: id, data: data)
			allTiles[id] = tile
			for border in tile.borders {
				allBorders[border] = (allBorders[border] ?? []) + [id]
			}
		}
	}

	required init() {}
}

/*
0:
 0 .####...  #####..#  ...###.. 23
 1 #####..#  ..#.#.##  ##..#.#. 22
 2 .#.#...#  .###...#  .##.O#.. 21
 3 #.O.##.O  O#.#.OO.  ##.OOO## 20
 4 ..#O.#O#  .O##O..O  .#O##.## 19
 5 ...#.#..  ##.##...  #..#..## 18
 6 #.##.#..  #.#..#..  ##.#.#.. 17
 7 .###.##.  ....#...  ###.#... 16

 8 #.####.#  .#....##  .#..#.#. 15
 9 ##...#..  #....#..  #...#### 14
10 ..#.##..  .###..#.  #####..# 13
11 ....#.##  .#.#####  ....#... 12
12 ..##.##.  ###.....  #.##..#. 11
13 #...#...  ###..###  #....##. 10
14 .#.##...  #.##.#.#  .###...#  9
15 #.###.#.  .####...  ##..#...  8

16 #.###...  #.##...#  .##O###.  7
17 .O##.#OO  .###OO##  ..OOO##.  6
18 ..O#.O..  O..O.#O#  #O##.###  5
19 #.#..##.  ########  ..#..##.  4
20 #.#####.  .#.#...#  #..#....  3
21 #....##.  .#.#####  ####..##  2
22 #...#...  ..#..##.  ..###.##  1
23 #..###..  ..##.#..  .##.##.#  0


180:
 0 #.##.##.  ..#.##..  #.###...
 1 ##.###..  .##..#..  .###.###
 2 ##..####  #####.#.  ..##.#..
 3 ....#..#  #...#.#.  #.#..##.
 4 .##..#..  ########  #.#####.
 5 ###.##X#  #X#.X..X  #....##.
 6 .##XXX..  ##XX###.  #...#...
 7 .###X##.  #...##.#  #..###..

 8 ...#..##  ...####.  .#.###.#
 9 #...###.  #.#.##.#  ...##.#.
10 .##....#  ###..###  ...#...#
11 .#..##.#  .....###  .##.##..
12 ...#....  #####.#.  ##.#....
13 #..#####  .#..###.  ..##.#..
14 ####...#  ..#....#  ..#...##
15 .#.#..#.  ##....#.  #.####.#

16 ...#.###  ...#....  .##.###.
17 ..#.#.##  ..#..#.#  ..#.##.#
18 ##..#..#  ...##.##  ..#.#...
19 ##.##O#.  O..O##O.  #O#.O#..
20 ##OOO.##  .OO.#.#O  O.##.O.#
21 ..#O.##.  #...###.  #...#.#.
22 .#.#..##  ##.#.#..  #..#####
23 ..###...  #..#####  ...####.
*/