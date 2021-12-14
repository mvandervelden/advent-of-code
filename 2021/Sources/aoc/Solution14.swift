class Solution14: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let input = file.lines

    var polymer = Array(input[0])

    // parse rules
    let rules = input[2...].reduce(into: [String: Character]()) { dict, line in
      let parts = line.components(separatedBy: " -> ")
      dict[String(parts[0])] = parts[1].first!
    }

    print(String(polymer))

    for _ in 0..<10 {
      var i = 0
      while i < polymer.count - 1 {
        let part = String(polymer[i...i+1])
        if let substitute = rules[part] ?? rules[String(part.reversed())] {
          polymer.insert(substitute, at: i+1)
          i+=2
        } else {
          print("no rule for: \(part)")
          i+=1
        }
      }
    }

    let counts = polymer.reduce(into: [Character: Int]()) { $0[$1, default: 0] += 1 }

    var maxCount = 0
    var minCount = Int.max

    for (_, count) in counts {
      if count > maxCount { maxCount = count }
      if count < minCount { minCount = count }
    }
    print(String(polymer))
    print(counts)


    return (maxCount - minCount).description
  }

  func solve2() -> String {
    let input = file.lines

    var polymerPairs: [String: Int] = [:]

    // Initialize by using a Dictionary of pairs, keeping count of how many each occurs
    let initialPolymer = Array(input[0])
    for i in 0..<(initialPolymer.count - 1) {
      polymerPairs[String(initialPolymer[i...i+1]), default: 0] += 1
    }

    // Parse the substitution rules
    let rules = input[2...].reduce(into: [String: Character]()) { dict, line in
      let parts = line.components(separatedBy: " -> ")
      dict[String(parts[0])] = parts[1].first!
    }

    for n in 0..<40 {
      // Go over pairs, find matching rule, add the 2 substitutes, and add those `count` times to the new Dict.
      var newPairs: [String: Int] = [:]
      for (pair, count) in polymerPairs {
        if let substitute = rules[pair] ?? rules[String(pair.reversed())] {
          newPairs[String([pair.first!, substitute]), default: 0] += count
          newPairs[String([substitute, pair.last!]), default: 0] += count
        } else { fatalError("no rule found!") }
      }
      polymerPairs = newPairs
    }

    // Count all letter occurrences, first in pairs
    var tmpCounts: [Character: Int]  = [:]
    for (pair, count) in polymerPairs {
      tmpCounts[pair.first!, default: 0] += count
      tmpCounts[pair.last!, default: 0] += count
    }

    // Then for each letter, calculate the proper amount
    let counts = tmpCounts.reduce(into: [Character: Int]()) {
      $0[$1.0] = ($1.1 + 1) / 2
    }

    // Calculate the min and max counts
    var maxCount = 0
    var minCount = Int.max
    for (char, count) in counts {
      if count > maxCount { maxCount = count }
      if count < minCount { minCount = count }
    }

    print(counts)
    return (maxCount - minCount).description
  }
}
