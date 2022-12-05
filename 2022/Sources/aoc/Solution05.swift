class Solution05: Solving {
  struct Move: CustomStringConvertible, Equatable {
    let amount: Int
    let from: Int
    let to: Int

    // Regex type only available on macOS 13.0+
    // private static var regex = try! Regex("/move (/d+) from (/d) to (/d)/")

    init(string: String) {
      // guard let match = string.firstMatch(of: regex) else { fatalError("unexpected input") }

      // amount = Int(match.1)!
      // from = Int(match.2)!
      // to = Int(match.3)!

      let words = string.split(separator: " ")
      amount = Int(words[1])!
      from = Int(words[3])! - 1
      to = Int(words[5])! - 1
    }

    var description: String {
      "move \(amount) from \(from) to \(to)"
    }
  }

  lazy var state: [[Character]] = {
    if file.filename == "input.txt" {
      return [
        Array("NSDCVQT"),
        Array("MFV"),
        Array("FQWDPNHM"),
        Array("DQRTF"),
        Array("RFMNQHVB"),
        Array("CFGNPWQ"),
        Array("WFRLCT"),
        Array("TZNS"),
        Array("MSDJRQHN")
      ]
    } else {
      return [
        Array("ZN"),
        Array("MCD"),
        Array("P")
      ]
    }
  }()

  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let moves = file.lines.map(Move.init)

    for move in moves {
      for _ in 0..<move.amount {
        let moving = state[move.from].popLast()!
        state[move.to].append(moving)
      }
    }

    return String(state.map { $0.last! })
  }

  func solve2() -> String {
    let moves = file.lines.map(Move.init)

    for move in moves {
      var moving: [Character] = []

      for _ in 0..<move.amount {
        moving.insert(state[move.from].popLast()!, at: 0)
      }

      state[move.to].append(contentsOf: moving)
    }

    return String(state.map { $0.last! })
  }
}

