class Solution15: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    return solve(iterations: 2020).description
  }

  func solve2() -> String {
    return solve(iterations: 30_000_000).description
  }

  func solve(iterations: Int) -> Int {
    let starting = file.lines.first!.split(separator: ",").map { Int($0)! }

    var list: [Int] = []
    var numbers: [Int: [Int]] = [:]
    for turn in 0..<iterations {
      if turn % 100_000 == 0 {
        print(turn)
      }
      let newVal: Int

      if turn < starting.count {
        newVal = starting[turn]
      } else {
        let prev = list.last!
        let turns = numbers[prev]!
        if turns.count > 1 {
          newVal = turns[0] - turns [1]
        } else {
          newVal = 0
        }
      }
      list.append(newVal)
      numbers[newVal] = [turn] + numbers[newVal, default: []].prefix(1)
    }

    return list.last!
  }
}
