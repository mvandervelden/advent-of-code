class Solution25: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let result = file.charsByLine.reduce([Character("0")]) { result, next in
      let s = sum(result, next)
      print(String(result), "+", String(next), "=", String(s))
      return s
    }

    return String(result).description
  }

  private func sum(_ lhs: [Character], _ rhs: [Character]) -> [Character] {
    let longest = Array(lhs.count >= rhs.count ? lhs.reversed() : rhs.reversed())
    let shortest = Array(lhs.count < rhs.count ? lhs.reversed() : rhs.reversed())

    var remainder: Character = "0"
    var sum: [Character] = []

    for i in 0..<longest.count {
      if i < shortest.count {
        let (s1, r1) = ssum(longest[i], remainder)
        let (s2, r2) = ssum(s1, shortest[i])
        sum.append(s2)
        remainder = ssum(r1, r2).sum
      } else {
        let (s, r) = ssum(longest[i], remainder)
        sum.append(s)
        remainder = r
      }
    }
    if remainder != "0" {
      sum.append(remainder)
    }

    return sum.reversed()
  }

  private func ssum(_ lhs: Character, _ rhs: Character) -> (sum: Character, remainder: Character) {
    switch (lhs, rhs) {
    case ("=", "="):              return (sum: "1", remainder: "-")
    case ("=", "-"), ("-", "="):  return (sum: "2", remainder: "-")
    case ("=", "0"), ("0", "="),
         ("-", "-"):              return (sum: "=", remainder: "0")
    case ("=", "1"), ("1", "="),
         ("-", "0"), ("0", "-"):  return (sum: "-", remainder: "0")
    case ("=", "2"), ("2", "="),
         ("-", "1"), ("1", "-"),
         ("0", "0"):              return (sum: "0", remainder: "0")
    case ("-", "2"), ("2", "-"),
         ("0", "1"), ("1", "0"):  return (sum: "1", remainder: "0")
    case ("0", "2"), ("2", "0"),
         ("1", "1"):              return (sum: "2", remainder: "0")
    case ("1", "2"), ("2", "1"):  return (sum: "=", remainder: "1")
    case ("2", "2"):              return (sum: "-", remainder: "1")
    default: fatalError("unexpected input \(lhs) + \(rhs)")
    }
  }

  func solve2() -> String {
    return file.filename
  }
}
