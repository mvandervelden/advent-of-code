class Solution06: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    return file
      .wordsSplitByEmptyLine
      .lazy
      .map { $0.flatMap(Array.init) }
      .map(Set.init)
      .map(\.count)
      .sum()
      .description
  }

  func solve2() -> String {
    let groups = file.wordsSplitByEmptyLine

    return groups
      .map { group in
        let groupSize = group.count
        let charArray = group.flatMap(Array.init)
        let charSet = Set(charArray)

        return charSet
          .map { char in charArray.count { $0 == char } }
          .map { $0 >= groupSize }
          .count { $0 }
      }
      .sum()
      .description
  }
}
