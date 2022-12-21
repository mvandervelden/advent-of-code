class Solution20: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    var list = file.lines.map { Int($0)! }
    var indices = Array(0..<list.count)

    for i in 0..<list.count {
      // print("i", i)
      // print(list)
      // print(indices)
      let val = list[indices[i]]
      // print("val", val)
      var newIndex = indices[i] + val
      // print("newIndex", newIndex)
      list.remove(at: indices[i])

      ((i+1)..<indices.count).forEach {
        indices[$0] -= 1
      }

      let mod = newIndex % list.count
      newIndex = mod >= 0 ? mod : mod + list.count

      list.insert(val, at: newIndex)
      ((newIndex+1)..<indices.count).forEach {
        indices[$0] += 1
      }
    }

    // print(list)
    // print(indices)

    let index0 = list.firstIndex(of: 0)!
    // print(index0)
    let s = [1000, 2000, 3000].map {
      print(list[(index0 + $0) % list.count])
      return list[(index0 + $0) % list.count]
    }.sum()

    return s.description
  }

  func solve2() -> String {
    return file.filename
  }
}

