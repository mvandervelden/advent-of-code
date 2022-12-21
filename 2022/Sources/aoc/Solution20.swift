class Solution20: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  struct Node: CustomStringConvertible, Equatable, Hashable {
    let index: Int
    let val: Int

    var description: String {
      "(\(index): \(val))"
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.index == rhs.index
    }
  }

  func solve1() -> String {
    var list = file.lines.enumerated().map { Node(index: $0, val: Int($1)!) }

    for i in 0..<list.count {
      // print("i", i)
      // print(list)
      // print(indices)
      let (curIndex, node) = list.enumerated().first { $1.index == i }!
      // print("val", val)
      var newIndex = curIndex + node.val
      // print("newIndex", newIndex)
      list.remove(at: curIndex)

      let mod = newIndex % list.count
      newIndex = mod >= 0 ? mod : mod + list.count

      list.insert(node, at: newIndex)
    }

    // print(list)
    // print(indices)

    let index0 = list.firstIndex { $0.val == 0 }!
    // print(index0)
    let s = [1000, 2000, 3000].map {
      print(list[(index0 + $0) % list.count])
      return list[(index0 + $0) % list.count].val
    }.sum()

    return s.description
  }

  func solve2() -> String {
    var list = file.lines.enumerated().map { Node(index: $0, val: Int($1)! * 811_589_153) }

    for v in 0..<10 {
      print(v)
      for i in 0..<list.count {
        // print("i", i)
        // print(list)
        // print(indices)
        let (curIndex, node) = list.enumerated().first { $1.index == i }!
        // print("val", val)
        var newIndex = curIndex + node.val
        // print("newIndex", newIndex)
        list.remove(at: curIndex)

        let mod = newIndex % list.count
        newIndex = mod >= 0 ? mod : mod + list.count

        list.insert(node, at: newIndex)
      }
    }

    // print(list)
    // print(indices)

    let index0 = list.firstIndex { $0.val == 0 }!
    // print(index0)
    let s = [1000, 2000, 3000].map {
      print(list[(index0 + $0) % list.count])
      return list[(index0 + $0) % list.count].val
    }.sum()

    return s.description
  }
}

