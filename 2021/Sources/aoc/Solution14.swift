class Solution14: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let input = file.lines

    var polymer = Array(input[0])

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
      // print(String(polymer))
    }

    let counts = polymer.reduce(into: [Character: Int]()) { $0[$1, default: 0] += 1 }

    var max: Character = " "
    var maxCount = 0
    var min: Character = " "
    var minCount = Int.max

    for (char, count) in counts {
      if count > maxCount { maxCount = count; max = char }
      if count < minCount { minCount = count; min = char }
    }
    print(String(polymer))
    print(counts)


    return (maxCount - minCount).description
  }

  func solve2() -> String {
    let input = file.lines

    var polymer = Array(input[0])

    let rules = input[2...].reduce(into: [String: Character]()) { dict, line in
      let parts = line.components(separatedBy: " -> ")
      dict[String(parts[0])] = parts[1].first!
    }

    print(String(polymer))

    for n in 0..<40 {
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
      print(n)
      // print(String(polymer))
    }

    let counts = polymer.reduce(into: [Character: Int]()) { $0[$1, default: 0] += 1 }

    var max: Character = " "
    var maxCount = 0
    var min: Character = " "
    var minCount = Int.max

    for (char, count) in counts {
      if count > maxCount { maxCount = count; max = char }
      if count < minCount { minCount = count; min = char }
    }
    print(String(polymer))
    print(counts)


    return (maxCount - minCount).description  }
}
