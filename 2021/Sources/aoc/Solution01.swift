class Solution01: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let numbers = file.lines.map { Int($0)! }
    var result = 0

    for i in 1..<numbers.count {
      result += numbers[i] > numbers[i-1] ? 1 : 0
    }

    return result.description
  }

  func solve2() -> String {
    let numbers = file.lines.map { Int($0)! }

    var windows: [Int] = []

    for i in 2..<numbers.count {
      windows.append(numbers[i-2] + numbers[i-1] + numbers[i])
    }

    var result = 0

    for i in 1..<windows.count {
      result += windows[i] > windows[i-1] ? 1 : 0
    }

    return result.description
  }
}
