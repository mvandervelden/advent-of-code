class Solution03: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    return findTrees(offset: (x: 1, y: 3)).description
  }

  func solve2() -> String {
    let offsets = [
      (x: 1, y: 1),
      (x: 1, y: 3),
      (x: 1, y: 5),
      (x: 1, y: 7),
      (x: 2, y: 1)
    ]

    let results = offsets.map(findTrees)
    return results.reduce(1) { $0 * $1 }.description
  }

  func findTrees(offset: (x: Int, y: Int)) -> Int {
    let forest = file.charsByLine

    var position = (x: 0, y: 0)
    var treeCount = 0

    while position.x < forest.count {
      let result = forest[position.x][position.y]
      treeCount += (result == "#" ? 1 : 0)
      position = (position.x + offset.x, (position.y + offset.y) % forest[0].count)
    }

    return treeCount
  }
}
