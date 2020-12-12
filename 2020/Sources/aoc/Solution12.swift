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
      case ("F", "E", _): x += val
      case ("F", "W", _): x -= val
      case ("F", "N", _): y -= val
      case ("F", "S", _): y += val
      case ("E", _, _): x += val
      case ("W", _, _): x -= val
      case ("N", _, _): y -= val
      case ("S", _, _): y += val
      case ("L", "E", 90): dir = "N"
      case ("L", "E", 180): dir = "W"
      case ("L", "E", 270): dir = "S"
      case ("R", "E", 90): dir = "S"
      case ("R", "E", 180): dir = "W"
      case ("R", "E", 270): dir = "N"
      case ("L", "W", 90): dir = "S"
      case ("L", "W", 180): dir = "E"
      case ("L", "W", 270): dir = "N"
      case ("R", "W", 90): dir = "N"
      case ("R", "W", 180): dir = "E"
      case ("R", "W", 270): dir = "S"
      case ("L", "N", 90): dir = "W"
      case ("L", "N", 180): dir = "S"
      case ("L", "N", 270): dir = "E"
      case ("R", "N", 90): dir = "E"
      case ("R", "N", 180): dir = "S"
      case ("R", "N", 270): dir = "W"
      case ("L", "S", 90): dir = "E"
      case ("L", "S", 180): dir = "N"
      case ("L", "S", 270): dir = "W"
      case ("R", "S", 90): dir = "W"
      case ("R", "S", 180): dir = "N"
      case ("R", "S", 270): dir = "E"
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
      case ("F", _, _, _):
        xShip += xWP * val
        yShip += yWP * val
      case ("E", _, _, _): xWP += val
      case ("W", _, _, _): xWP -= val
      case ("N", _, _, _): yWP -= val
      case ("S", _, _, _): yWP += val
      case ("L", 90, let px, let py), ("R", 270, let px, let py): xWP = py; yWP = -px
      case ("L", 270, let px, let py), ("R", 90, let px, let py): xWP = -py; yWP = px
      case (_, 180, let px, let py): xWP = -px; yWP = -py
      default: preconditionFailure("Unexpected input: \(inst)\(val)")
      }
    }

    return (abs(xShip) + abs(yShip)).description
  }
}
