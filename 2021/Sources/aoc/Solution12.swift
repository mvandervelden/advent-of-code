class Solution12: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let lines = file.lines
    let insts = lines.map { $0.first! }
    let vals = lines.map { Int($0.dropFirst())! }

    var dir: Character = "E"
    var x = 0
    var y = 0

    for (inst, val) in zip(insts, vals) {
      switch (inst, dir, val) {
      case ("F", "E", _), ("E", _, _): x += val
      case ("F", "W", _), ("W", _, _): x -= val
      case ("F", "N", _), ("N", _, _): y -= val
      case ("F", "S", _), ("S", _, _): y += val
      case ("L", "E",  90), ("R", "E", 270),
           ("L", "W", 270), ("R", "W",  90),
           ("L", "S", 180), ("R", "S", 180): dir = "N"
      case ("L", "E", 180), ("R", "E", 180),
           ("L", "N",  90), ("R", "N", 270),
           ("L", "S", 270), ("R", "S",  90): dir = "W"
      case ("L", "E", 270), ("R", "E",  90),
           ("L", "W",  90), ("R", "W", 270),
           ("L", "N", 180), ("R", "N", 180): dir = "S"
      case ("L", "W", 180), ("R", "W", 180),
           ("L", "N", 270), ("R", "N",  90),
           ("L", "S",  90), ("R", "S", 270): dir = "E"
      default: preconditionFailure("Unexpected input: \(inst)\(val)")
      }
    }

    return (abs(x) + abs(y)).description
  }

  func solve2() -> String {
    let lines = file.lines
    let insts = lines.map { $0.first! }
    let vals = lines.map { Int($0.dropFirst())! }

    var xShip = 0
    var yShip = 0
    var xWP = 10
    var yWP = -1

    for (inst, val) in zip(insts, vals) {
      switch (inst, val, xWP, yWP) {
      case ("F", _, _, _): xShip += xWP * val; yShip += yWP * val
      case ("E", _, _, _): xWP += val
      case ("W", _, _, _): xWP -= val
      case ("N", _, _, _): yWP -= val
      case ("S", _, _, _): yWP += val
      case ("L",  90, let px, let py),
           ("R", 270, let px, let py): xWP = py; yWP = -px
      case ("L", 270, let px, let py),
           ("R",  90, let px, let py): xWP = -py; yWP = px
      case (  _, 180, let px, let py): xWP = -px; yWP = -py
      default: preconditionFailure("Unexpected input: \(inst)\(val)")
      }
    }

    return (abs(xShip) + abs(yShip)).description
  }
}
