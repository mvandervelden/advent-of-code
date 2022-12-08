class Solution08: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let grid = file.charsByLine.map { $0.map { Int(String($0))! } }

    let height = grid.count
    let width = grid[0].count

    var visibilityGrid = Array(repeating: Array(repeating: 0, count: width), count: height)

    var visibilityFromTop = Array(repeating: Array(repeating: -1, count: width), count: height)
    var visibilityFromLeft = Array(repeating: Array(repeating: -1, count: width), count: height)
    var visibilityFromRight = Array(repeating: Array(repeating: -1, count: width), count: height)
    var visibilityFromBottom = Array(repeating: Array(repeating: -1, count: width), count: height)

    visibilityFromTop[0] = grid[0]
    visibilityGrid[0] = Array(repeating: 1, count: width)
    visibilityFromBottom[height-1] = grid[height-1]
    visibilityGrid[height-1] = Array(repeating: 1, count: width)

    for y in 0..<(height) {
      visibilityFromLeft[y][0] = grid[y][0]
      visibilityFromRight[y][width-1] = grid[y][width-1]
      visibilityGrid[y][0] = 1
      visibilityGrid[y][width-1] = 1
    }

    for y in 1..<(height-1) {
      for x in 1..<(width-1) {
        if visibilityFromTop[y-1][x] < grid[y][x] {
          visibilityGrid[y][x] = 1
          visibilityFromTop[y][x] = grid[y][x]
        } else {
          visibilityFromTop[y][x] = visibilityFromTop[y-1][x]
        }

        if visibilityFromLeft[y][x-1] < grid[y][x] {
          visibilityGrid[y][x] = 1
          visibilityFromLeft[y][x] = grid[y][x]
        } else {
          visibilityFromLeft[y][x] = visibilityFromLeft[y][x-1]
        }

        let yBottom = height-y-1
        let xRight = width-x-1

        if visibilityFromBottom[yBottom+1][xRight] < grid[yBottom][xRight] {
          visibilityGrid[yBottom][xRight] = 1
          visibilityFromBottom[yBottom][xRight] = grid[yBottom][xRight]
        } else {
          visibilityFromBottom[yBottom][xRight] = visibilityFromBottom[yBottom+1][xRight]
        }

        if visibilityFromRight[yBottom][xRight+1] < grid[yBottom][xRight] {
          visibilityGrid[yBottom][xRight] = 1
          visibilityFromRight[yBottom][xRight] = grid[yBottom][xRight]
        } else {
          visibilityFromRight[yBottom][xRight] = visibilityFromRight[yBottom][xRight+1]
        }
      }
    }

    print(grid.prettyDescription)
    print()
    print(visibilityGrid.prettyDescription)

    return visibilityGrid.sum().description
  }

  func solve2() -> String {
    return file.filename
  }
}
