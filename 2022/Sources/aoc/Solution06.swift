class Solution06: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
 var result = 0

    for line in file.charsByLine {
      result = findStartMarker(input: line, windowSize: 4)
    }

    return result.description
  }

  func solve2() -> String {
    var result = 0

    for line in file.charsByLine {
      result = findStartMarker(input: line, windowSize: 14)
    }

    return result.description
  }

  private func findStartMarker(input: [Character], windowSize: Int) -> Int {
    let offset = windowSize - 1

    for i in offset..<input.count {
      let section = input[(i-offset)...i]
      if Set(section).count == section.count {
        print(String(section), i + 1)
        return i + 1
      }
    }

    return -1
  }
}

