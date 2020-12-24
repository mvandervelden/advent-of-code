class Solution24: Solving {
  typealias Grid = [Pt: Bool]

  struct Pt: Hashable {
    let x: Int
    let y: Int
  }

  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let grid = createGrid()

    return countBlacks(in: grid).description
  }

  func countBlacks(in grid: Grid) -> Int {
    return grid.values.reduce(0) { $0 + ($1 ? 1 : 0) }
  }

  func solve2() -> String {
    var grid = createGrid()
    var next = grid
    for i in 1...100 {
      let allBlacks = blackTiles(in: grid)
      var allWhiteNeighbors: [Pt: Int] = [:]

      for tile in allBlacks {
        let ns = neighbors(pt: tile)
        var blackNeighborCount = 0

        for pt in ns {
          let isBlack = grid[pt] == true
          if isBlack {
            blackNeighborCount += 1
          } else {
            allWhiteNeighbors[pt, default: 0] += 1
          }
        }
        // switch some blacks to white
        if blackNeighborCount == 0 || blackNeighborCount > 2 {
          next[tile] = false
        }
      }
      // switch some whites to black
      for val in allWhiteNeighbors {
        if val.value == 2 {
          next[val.key] = true
        }
      }

      grid = next
      print("Round \(i): \(countBlacks(in: grid))")
    }

    return countBlacks(in: grid).description
  }

  //   -3 -2 -1  0  1  2  3
  //-1  x     x     x     x
  // 0     x     x     x
  //+1  x     x     x     x
  func createGrid() -> Grid {
    var grid: Grid = [:]
    let lines = file.charsByLine
    for line in lines {
      var x = 0
      var y = 0

      var i = 0
      while i < line.count {
        switch line[i] {
        case "e": x += 2
        case "w": x -= 2
        case "s":
          y+=1
          if line[i+1] == "e" {
            x += 1
          } else {
            x -= 1
          }
          i += 1
        case "n":
          y-=1
          if line[i+1] == "e" {
            x += 1
          } else {
            x -= 1
          }
          i += 1
        default: preconditionFailure("unexpecteed input: \(line[i])")
        }
        i += 1
      }
      grid[Pt(x: x, y: y), default: false].toggle()
    }
    return grid
  }

  func blackTiles(in grid: Grid) -> [Pt] {
    return grid.filter { $0.value }.map { $0.key }
  }

  func neighbors(pt: Pt) -> [Pt] {
    return [
      Pt(x: pt.x + 2, y: pt.y),     // e
      Pt(x: pt.x + 1, y: pt.y + 1), // se
      Pt(x: pt.x - 1, y: pt.y + 1), // sw
      Pt(x: pt.x - 2, y: pt.y),     // w
      Pt(x: pt.x - 1, y: pt.y - 1), // nw
      Pt(x: pt.x + 1, y: pt.y - 1)  // ne
    ]
  }
}
