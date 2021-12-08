class Solution08: Solving {
  enum SevenSegmentDigit: String {
    case zero =  "abcefg"
    case one =   "cf"
    case two =   "acdeg"
    case three = "acdfg"
    case four =  "bcdf"
    case five =  "abdfg"
    case six =   "abdefg"
    case seven = "acf"
    case eight = "abcdefg"
    case nine =  "abcdfg"

    static var uniqueLengths: Set<Int> = [2, 3, 4, 7]

    var numVal: String {
      switch self {
      case .zero: return "0"
      case .one: return "1"
      case .two: return "2"
      case .three: return "3"
      case .four: return "4"
      case .five: return "5"
      case .six: return "6"
      case .seven: return "7"
      case .eight: return "8"
      case .nine: return "9"
      }
    }
  }

  struct Entry: CustomStringConvertible {
    let signalPatterns: [String]
    let outputValue: [String]

    init(string: String) {
      let parts = string.components(separatedBy: " | ")
      signalPatterns = parts[0].split(separator: " ").map(String.init)
      outputValue = parts[1].split(separator: " ").map(String.init)
    }

    func deduce() -> [Character: Character] {
      var mapping: [Character: Character] = [:]

      let one = Array(signalPatterns.first { $0.count == 2 }!)
      let seven = Array(signalPatterns.first { $0.count == 3 }!)
      let four = Array(signalPatterns.first { $0.count == 4 }!)
      let twoThreeFive = signalPatterns.filter { $0.count == 5 }.map(Array.init)
      let zeroSixNine = signalPatterns.filter { $0.count == 6 }.map(Array.init)

      let aPosition = seven.first { !one.contains($0) }!
      mapping[aPosition] = "a"
      let charArray = Array("abcdefg")

      for p in charArray {
        let count = twoThreeFive.count { $0.contains(p) }
        if count == 1 {
          if four.contains(p) {
            mapping[p] = "b"
          } else {
            mapping[p] = "e"
          }
        } else if count == 3 && p != aPosition {
          if four.contains(p) {
            mapping[p] = "d"
          } else {
            mapping[p] = "g"
          }
        }
      }

      for p in charArray {
        let count = zeroSixNine.count { $0.contains(p) }
        if count == 3 && one.contains(p) {
            mapping[p] = "f"
        }
      }

      for p in charArray {
        if mapping[p] == nil {
          mapping[p] = "c"
        }
      }

      return mapping
    }

    func map(mapping: [Character: Character]) -> [SevenSegmentDigit] {
      let values = outputValue
        .map(Array.init)

      var result: [SevenSegmentDigit] = []
      for v in values {
        let digit = v.map { mapping[$0]! }.sorted()
        let sevenSegment = SevenSegmentDigit(rawValue: String(digit))!
        result.append(sevenSegment)
      }

      return result
    }

    var description: String {
      return signalPatterns.description + " | " + outputValue.description
    }
  }

  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let lines = file.lines.map(Entry.init)

    let oneFourSevenEightCount = lines.reduce(0) { sum, line in
      let uniqueLengthsCount = line.outputValue
        .map { $0.count }
        .count { SevenSegmentDigit.uniqueLengths.contains($0) }
      return sum + uniqueLengthsCount
    }

    return oneFourSevenEightCount.description
  }

  func solve2() -> String {
    let lines = file.lines.map(Entry.init)
    var results: [String] = []

    for line in lines {
      let mapping = line.deduce()
      let outputValue = line.map(mapping: mapping)
      let numString = outputValue.map(\.numVal).joined()
      results.append(numString)
    }

    let sum = results.reduce(0) { $0 + Int($1)! }

    return sum.description
  }
}
