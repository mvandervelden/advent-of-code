class Solution13: Solving {
  enum Packet: CustomStringConvertible, Equatable, Comparable {
    case int(Int)
    case list([Packet])

    init(_ chars: [Character]) {
      let string = String(chars)
      // print("parsing", string)

      if let int = Int(string) {
        self = .int(int)
        return
      }

      var list: [Packet] = []
      var depth = 0
      var currentStart = 1
      // print("range 1..<\(chars.count-1)")
      for i in 1..<(chars.count-1) {
        // print(i, chars[i])
        if chars[i] == "[" {
          // print("[ -> setting start")
          if depth == 0 { currentStart = i }

          depth += 1
        } else if depth == 1 && chars[i] == "]" {
          // print("range \(currentStart)...\(i)")
          // print("] -> storing list \(String(chars[currentStart...i]))")
          list.append(Packet(Array(chars[currentStart...i])))
          currentStart = i+2
          depth = 0
        } else if chars[i] == "]" {
          depth -= 1
        } else if depth == 0 && chars[i] == "," && chars[i-1] == "]" {
          // print("pass")
        } else if depth == 0 && chars[i] == "," {
          // print("range \(currentStart)..<\(i)")
          // print(", -> storing previous element \(String(chars[currentStart..<i]))")
          // print(chars[currentStart..<i])
          // print(",")
          list.append(Packet(Array(chars[currentStart..<i])))
          currentStart = i+1
        } else if depth == 0 {
          // print("pass")
        }

        // print(i, list)
      }

      if currentStart < chars.count-1 {
        // print("end -> parsing \(String(chars[currentStart..<(chars.count-1)]))")
        list.append(Packet(Array(chars[currentStart..<(chars.count-1)])))
      }
      // print(list)

      self = .list(list)
    }

    var description: String {
      switch self {
      case .int(let int): return "\(int)"
      case .list(let list): return "[" + list.map(\.description).joined(separator: ",") + "]"
      }
    }

    static func < (lhs: Packet, rhs: Packet) -> Bool {
      return (compare(lhs, rhs) ?? 1) == 1
    }

    private static func compare(_ lhs: Packet, _ rhs: Packet) -> Int? {
      // 1 if correct order, 0 if incorrect, nil is undecided
      switch (lhs, rhs) {
      case (.int(let lhs), .int(let rhs)):
        if lhs < rhs { return 1 }
        if lhs > rhs { return 0 }
        return nil
      case (.int, .list):
        return compare(.list([lhs]), rhs)
      case (.list, .int):
        return compare(lhs, .list([rhs]))
      case (.list([]), .list([])):
        return nil
      case (.list([]), .list):
        return 1
      case (.list, .list([])):
        return 0
      case (.list(let lhs), .list(let rhs)):
        if let result = compare(lhs[0], rhs[0]) {
          return result
        }

        return compare(.list(Array(lhs[1...])), .list(Array(rhs[1...])))
      }
    }
  }

  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let pairs = file.linesSplitByEmptyLine

    let packets = pairs.enumerated().map { index, pair in
      let packets = pair.map { Packet(Array($0)) }
      return (index + 1) * (compare(packets[0], packets[1]) ?? 1)
    }.sum()

    return packets.description
  }

  func solve2() -> String {
    var lines = file.lines.filter { $0.count > 0 }
    lines.append("[[2]]")
    lines.append("[[6]]")

    let packets = lines.map { Packet(Array($0)) }.sorted()
    let div2 = packets.firstIndex(of: .list([.list([.int(2)])]))! + 1
    let div6 = packets.firstIndex(of: .list([.list([.int(6)])]))! + 1

    return (div2 * div6).description
  }

  private func compare(_ lhs: Packet, _ rhs: Packet) -> Int? {
    // 1 if correct order, 0 if incorrect, nil is undecided
    switch (lhs, rhs) {
    case (.int(let lhs), .int(let rhs)):
      if lhs < rhs { return 1 }
      if lhs > rhs { return 0 }
      return nil
    case (.int, .list):
      return compare(.list([lhs]), rhs)
    case (.list, .int):
      return compare(lhs, .list([rhs]))
    case (.list([]), .list([])):
      return nil
    case (.list([]), .list):
      return 1
    case (.list, .list([])):
      return 0
    case (.list(let lhs), .list(let rhs)):
      if let result = compare(lhs[0], rhs[0]) {
        return result
      }

      return compare(.list(Array(lhs[1...])), .list(Array(rhs[1...])))
    }
  }
}

