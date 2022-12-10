class Solution10: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let instructions = file.words

    let checkpoints = [20, 60, 100, 140, 180, 220]
    var x = 1
    var cycle = 1
    var result = 0

    for instr in instructions {
      if cycle > 220 { break }
      if checkpoints.contains(cycle) {
        print("hit:", cycle, x, instr)
        result += cycle * x
        print("result:", result)
      } else if checkpoints.contains(cycle + 1) && instr[0] == "addx" {
        print("hit next:", cycle, x, instr)
        result += (cycle + 1) * x
        print("result:", result)
      }

      switch instr[0] {
      case "addx":
        cycle += 2
        x += Int(instr[1])!
      case "noop":
        cycle += 1
      default:
        fatalError()
      }
    }
    print(cycle)
    return result.description
  }

  func solve2() -> String {
    let instructions = file.words

    var screen: [[Character]] = []
    var line: [Character] = []
    var x = 1
    var cycle = 1

    for instr in instructions {
      let offset = ((cycle - 1) % 40)
      let nextOffset = (cycle % 40)

      if offset == 0 {
        screen.append(line)
        line = []
      }

      if [x-1, x, x+1].contains(offset) {
        line.append("#")
      } else {
        line.append(".")
      }

      switch instr[0] {
      case "addx":
        if nextOffset == 0 {
          screen.append(line)
          line = []
        }
        if [x-1, x, x+1].contains(nextOffset) {
          line.append("#")
        } else {
          line.append(".")
        }
        cycle += 2
        x += Int(instr[1])!
      case "noop":
        cycle += 1
      default:
        fatalError()
      }
    }
    screen.append(line)
    print(cycle)
    print(screen.map {String($0)}.joined(separator: "\n"))
    return x.description
  }
}

