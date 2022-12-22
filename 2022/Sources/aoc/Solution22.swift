class Solution22: Solving {
  enum Instruction: CustomStringConvertible {
    case left
    case right
    case forward(Int)

    var description: String {
      switch self {
      case .left: return "L"
      case .right: return "R"
      case .forward(let int): return "\(int)"
      }
    }
  }

  enum Orientation: String {
    case up = "^"
    case down = "V"
    case left = "<"
    case right = ">"

    mutating func rotate(_ direction: Instruction) {
      switch direction {
      case .forward: break
      case .right:
        switch self {
          case .up: self = .right
          case .right: self = .down
          case .down: self = .left
          case .left: self = .up
        }
      case .left:
        switch self {
          case .up: self = .left
          case .left: self = .down
          case .down: self = .right
          case .right: self = .up
        }
      }
    }

    var score: Int {
      switch self {
      case .right: return 0
      case .down: return 1
      case .left: return 2
      case .up: return 3
      }
    }
  }

  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let input = file.linesSplitByEmptyLine
    var grid = input[0].map { Array($0) }
    let instructions = construct(input[1][0])

    var location = Point2D(x: grid[0].firstIndex(of: ".")!, y: 0)
    var orientation = Orientation.right

    for instr in instructions {
      // print(instr, ":", location, orientation)
      // print(grid.prettyDescription)
      orientation.rotate(instr)
      grid[location.y][location.x] = Array(orientation.rawValue)[0]

      if case .forward(let amount) = instr {
        switch orientation {
        case .right:
          let y = location.y
          let row = grid[y]
          var hitWall = false

          for _ in 0..<amount where !hitWall {
            let x = location.x + 1
            var newX = x % row.count
            // print(i, newX)
            if row[newX] == " " {
              newX = row.firstIndex { $0 != " " }!
              // print("found space, new", newX)
            }

            switch row[newX] {
            case "#":
              // print("hit wall", x, "->", newX, y, row[newX])
              hitWall = true
            default:
              // print("walking", x, "->", newX, y, row[newX])
              grid[y][newX] = ">"
              location = Point2D(x: newX, y: y)
            }
          }
        case .left:
          let y = location.y
          let row = grid[y]
          var hitWall = false
          for _ in 0..<amount where !hitWall{
            let x = location.x - 1

            var newX = x % row.count
            if newX < 0 { newX += row.count }

            if row[newX] == " " {
              newX = row.count - 1
            }

            switch row[newX] {
            case "#":
              hitWall = true
            default:
              grid[y][newX] = "<"
              location = Point2D(x: newX, y: y)
            }
          }
        case .down:
          let x = location.x

          let col = grid.map { line in
            if x >= line.count {
              return Character(" ")
            } else {
              return line[x]
            }
          }

          var hitWall = false
          for _ in 0..<amount where !hitWall {
            let y = location.y + 1

            var newY = y % col.count
            // print(i, newY)
            if col[newY] == " " {
              newY = col.firstIndex { $0 != " " }!
              // print("found space, new", newY)
            }

            switch col[newY] {
            case "#":
              // print("hit wall", x, y, "->", newY, col[newY])
              hitWall = true
            default:
              // print("walking", x, y, "->", newY, col[newY])
              grid[newY][x] = "V"
              location = Point2D(x: x, y: newY)
            }
          }
        case .up:
          let x = location.x

          let col = grid.map { line in
            if x >= line.count {
              return Character(" ")
            } else {
              return line[x]
            }
          }
          var hitWall = false
          for _ in 0..<amount where !hitWall {
            let y = location.y - 1

            var newY = y % col.count
            if newY < 0 { newY += col.count }

            if col[newY] == " " {
              newY = col.lastIndex { $0 != " " }!
            }

            switch col[newY] {
            case "#":
              hitWall = true
            default:
              grid[newY][x] = "^"
              location = Point2D(x: x, y: newY)
            }
          }
        }
      }
    }

    print(grid.prettyDescription)
    print(location, orientation)
    let score = (location.y + 1) * 1000 + (location.x + 1) * 4 + orientation.score
    return score.description
  }

  func solve2() -> String {
    return file.filename
  }

  private func construct(_ input: String) -> [Instruction] {
    let arr = Array(input)
    var instructions: [Instruction] = []
    var currentNum: [Character] = []

    for c in arr {
      if c == "R" || c == "L", !currentNum.isEmpty {
        instructions.append(.forward(Int(String(currentNum))!))
        currentNum = []
      } else {
        currentNum.append(c)
      }

      if c == "R" {
        instructions.append(.right)
      } else if c == "L" {
        instructions.append(.left)
      }
    }

    if !currentNum.isEmpty {
      instructions.append(.forward(Int(String(currentNum))!))
    }

    return instructions
  }
}

