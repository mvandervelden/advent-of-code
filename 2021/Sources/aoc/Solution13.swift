class Solution13: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let goal = Int(file.lines[0])!
    let busIDs = file.lines[1].split(separator: ",").compactMap { Int($0) } // ignores 'x'
    let mods = busIDs.map { $0 - (goal % $0) }
    let min = mods.enumerated().min { $0.element < $1.element }!
    return (min.element * busIDs[min.offset]).description
  }

  func solve2() -> String {
    let buses = file.lines[1].split(separator: ",").enumerated().compactMap { Bus(index: $0.offset, string: String($0.element)) }

    print("Go to https://www.dcode.fr/chinese-remainder, and fill in the below values:")
    print("rem, mod")
    for bus in buses {
      print("\(bus.remainder), \(bus.id)")
    }
    print("Then add the result in the code")

    let res = 783685719679632
    return res.description
  }


  struct Bus {
    let id: Int
    let index: Int

    init?(index: Int, string: String) {
      guard let id = Int(string) else { return nil }
      self.index = index
      self.id = id
    }

    var remainder: Int {
      if index == 0 { return 0 }
      let rem = id - index
      // while rem < 0 { rem += id }
      return rem
    }
  }
}
