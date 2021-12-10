class Solution10: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let lines = file.charsByLine

    var score = 0
    for line in lines {
      var openQueue: [Character] = []

      for char in line {
        if let opening = matchingClose(char) {
          openQueue.append(opening)
        } else {
          let expectingClose = openQueue.removeLast()
          if char != expectingClose {
            score += corruptionsScore(char)
            break
          }
        }
      }
    }

    return score.description
  }

  func solve2() -> String {
    let lines = file.charsByLine

    var scores: [Int] = []
    for line in lines {
      var openQueue: [Character] = []
      var isCorrupt = false

      for char in line {
        if let opening = matchingClose(char) {
          openQueue.append(opening)
        } else {
          let expectingClose = openQueue.removeLast()
          if char != expectingClose {
            isCorrupt = true
            break
          }
        }
      }

      if !isCorrupt {
        scores.append(completionScore(openQueue.reversed()))
      }
    }

    let middle = scores.sorted()[scores.count / 2]

    return middle.description
  }

  private func matchingClose(_ char: Character) -> Character? {
    switch char {
    case "(": return ")"
    case "[": return "]"
    case "{": return "}"
    case "<": return ">"
    default: return nil
    }
  }

  private func corruptionsScore(_ char: Character) -> Int {
    switch char {
      case ")": return 3
      case "]": return 57
      case "}": return 1197
      case ">": return 25137
      default: fatalError("unexpected scoring character '\(char)'")
    }
  }

  private func completionScore(_ chars: [Character]) -> Int {
    var total = 0

    for char in chars {
      total *= 5

      switch char {
        case ")": total += 1
        case "]": total += 2
        case "}": total += 3
        case ">": total += 4
        default: fatalError("unexpected scoring char '\(char)'")
      }
    }

    return total
  }
}
