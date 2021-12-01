class Solution01: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let numbers = file.lines.map { Int($0)! }
    var result = 0

    for n in numbers {
      for o in numbers where n + o == 2020 {
        result = n*o
      }
    }

    return result.description
  }

  func solve2() -> String {
    let numbers = file.lines.map { Int($0)! }
    var result = 0

    for n in numbers {
      for o in numbers {
        for p in numbers where n + o + p == 2020 {
          result = n*o*p
        }
      }
    }

    return result.description
  }
}
