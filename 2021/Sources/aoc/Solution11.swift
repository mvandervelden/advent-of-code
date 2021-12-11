class Solution11: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    var octos = file.charsByLine.map { line in line.map { Int(String($0))! } }
    var score = 0
    var history: [[[Int]]: (i: Int, score: Int)] = [:]

    for i in 1...100 {
      if let oldScore = history[octos] {
        let addition = score - oldScore.score
        let steps = i - oldScore.i
        let cycles = (100 - i) / steps
        score += cycles * addition
        let leftover = 100 - i + cycles * steps
        let leftoverScore = history.values.first { $0.i == oldScore.i + leftover }!.score - oldScore.score
        score += leftoverScore
        break
      } else {
        history[octos] = (i: i - 1, score: score)
      }

      var hits: [Point2D] = []

      for y in 0..<octos.count {
        for x in 0..<octos[0].count {
          octos[y][x] += 1
          if octos[y][x] == 10 {
            hits.append(Point2D(x: x, y: y))
          }
        }
      }

      while !hits.isEmpty {
        score += 1
        let hit = hits.removeLast()
        octos[hit.y][hit.x] = 0

        for n in hit.neighbors(maxX: octos[0].count - 1, maxY: octos.count - 1) {
          let nocto = octos[n.y][n.x]
          switch nocto {
          case 9:
            octos[n.y][n.x] += 1
            hits.append(n)
          case 1...8:
            octos[n.y][n.x] += 1
          default: continue
          }
        }
      }
    }

    return score.description
  }

  func solve2() -> String {
var octos = file.charsByLine.map { line in line.map { Int(String($0))! } }
    var score = 0
    var history: [[[Int]]: (i: Int, score: Int)] = [:]

    for i in 1...1000 {
      if let oldScore = history[octos] {
        let addition = score - oldScore.score
        let steps = i - oldScore.i
        let cycles = (100 - i) / steps
        score += cycles * addition
        let leftover = 100 - i + cycles * steps
        let leftoverScore = history.values.first { $0.i == oldScore.i + leftover }!.score - oldScore.score
        score += leftoverScore
        break
      } else {
        history[octos] = (i: i - 1, score: score)
      }

      var hits: [Point2D] = []
      var hitCount = 0
      for y in 0..<octos.count {
        for x in 0..<octos[0].count {
          octos[y][x] += 1
          if octos[y][x] == 10 {
            hits.append(Point2D(x: x, y: y))
          }
        }
      }

      while !hits.isEmpty {
        score += 1
        hitCount += 1
        let hit = hits.removeLast()
        octos[hit.y][hit.x] = 0

        for n in hit.neighbors(maxX: octos[0].count - 1, maxY: octos.count - 1) {
          let nocto = octos[n.y][n.x]
          switch nocto {
          case 9:
            octos[n.y][n.x] += 1
            hits.append(n)
          case 1...8:
            octos[n.y][n.x] += 1
          default: continue
          }
        }
      }

      if hitCount == 100 {
        return i.description
      }
    }

    return "Not found"
  }
}
