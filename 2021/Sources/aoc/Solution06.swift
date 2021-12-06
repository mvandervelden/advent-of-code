class Solution06: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    return algorithm(days: 80)
  }

  func solve2() -> String {
    return algorithm(days: 256)
  }

  private func algorithm(days: Int) -> String {
   let fish = file.csv[0].compactMap(Int.init)
    var tank: [Int: Int] = [:]

    for f in fish {
      tank[f, default:0] += 1
    }

    var pending1 = 0
    var pending2 = 0
    var newPending2 = 0
    var tankIdx = 6
    for i in 0..<days {
      tankIdx = i % 7

      newPending2 = tank[tankIdx] ?? 0
      tank[tankIdx, default: 0] += pending1
      pending1 = pending2
      pending2 = newPending2

      // print(i, tankIdx, tankDescription(tank: tank), tank.values.sum(), pending1, pending2, tank.values.sum() + pending1 + pending2)
    }

    let result = tank.values.sum() + pending2 + pending1
    return result.description
  }

  private func tankDescription(tank: [Int: Int]) -> String {
    var str = ""
    for i in 0..<7 {
      str += ",\(i):\(tank[i]?.description ?? "-")"
    }
    return str
  }
}
