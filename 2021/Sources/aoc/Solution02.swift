class Solution02: Solving {
  let file: File

  enum Dir: String {
    case forward, down, up
  }

  struct Inst: CustomStringConvertible {
    let dir: Dir
    let val: Int

    init(string: [String]) {
      dir = Dir(rawValue: string[0])!
      val = Int(string[1])!
    }

    var description: String {
      return "\(dir.rawValue) \(val.description)"
    }
  }

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let insts = file.words.map { Inst(string: $0) }

    var hor = 0
    var depth = 0

    for inst in insts {
      switch inst.dir {
      case .forward: hor += inst.val
      case .up: depth -= inst.val
      case .down: depth += inst.val
      }
    }

    return (hor * depth).description
  }

  func solve2() -> String {
    let insts = file.words.map { Inst(string: $0) }

    var hor = 0
    var depth = 0
    var aim = 0

    for inst in insts {
      switch inst.dir {
      case .forward:
        hor += inst.val
        depth += aim * inst.val
      case .up: aim -= inst.val
      case .down: aim += inst.val
      }
    }

    return (hor * depth).description
  }
}
