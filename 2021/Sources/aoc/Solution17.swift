class Solution17: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let isInput = file.filename == "input.txt"
    let targetY = isInput ? -93...(-67) : -10...(-5)

    var potentialYs: [(Int, Int)] = []

    for y in 0...100 {
      var posY = 0
      var i = 0
      var maxY = 0
      while posY >= targetY.first! {
        posY += y - i
        i += 1
        maxY = max(maxY, posY)
        if targetY.contains(posY) { potentialYs.append((y, maxY)); break }
      }
    }

    let bestY = potentialYs.last!

    return "maxY: \(bestY.1), y: \(bestY.0)"
  }

  func solve2() -> String {
    let isInput = file.filename == "input.txt"

    let targetX = isInput ? 195...238 : 20...30
    let targetY = isInput ? -93...(-67) : -10...(-5)

    let xRange = isInput ? 20...238 : 6...30

    var hits = 0

    for x in xRange {
      for y in targetY.first!...100 {
        var posX = 0
        var posY = 0
        var i = 0
        while posY >= targetY.first! && posX <= targetX.last! {
          posY += y - i
          posX += max(0, x - i)
          i += 1
          if targetY.contains(posY) && targetX.contains(posX) { hits += 1; break }
        }
      }
    }

    return hits.description
  }
}
