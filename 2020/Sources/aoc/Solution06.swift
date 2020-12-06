class Solution06: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let groups = file.wordsSplitByEmptyLine

    var counts: [Int] = []
    for group in groups {
      let charArray: [Character] = group.flatMap(Array.init)
      counts.append(Set(charArray).count)
    }
    return counts.sum().description
  }

  func solve2() -> String {
    let groups = file.wordsSplitByEmptyLine

    var counts: [Int] = []
    for group in groups {
      let groupSize = group.count
      let charArray: [Character] = group.flatMap(Array.init)
      let charSet = Set(charArray)

      var valids = 0
      for char in charSet {
        let occurrences = charArray.count { $0 == char }
        valids += (occurrences >= groupSize) ? 1 : 0
      }
      counts.append(valids)
    }
    return counts.sum().description
  }
}
