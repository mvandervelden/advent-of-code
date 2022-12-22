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

  var grid: [[Character]] = []
  var location: Point2D! {
    willSet {
      prevLocation = location
      didChangeDirection = false
    }
  }
  var prevLocation: Point2D!
  var didChangeDirection = false

  var orientation = Orientation.right {
    willSet {
      prevOrientation = orientation
    }
  }
  var prevOrientation = Orientation.right

  func solve1() -> String {
    let input = file.linesSplitByEmptyLine
    let instructions = construct(input[1][0])

    grid = input[0].map { Array($0) }
    location = Point2D(x: grid[0].firstIndex(of: ".")!, y: 0)
    orientation = Orientation.right

    for instr in instructions {
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
            if row[newX] == " " {
              newX = row.firstIndex { $0 != " " }!
            }

            switch row[newX] {
            case "#":
              hitWall = true
            default:
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
            if col[newY] == " " {
              newY = col.firstIndex { $0 != " " }!
            }

            switch col[newY] {
            case "#":
              hitWall = true
            default:
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
    print(location!, orientation)
    let score = (location.y + 1) * 1000 + (location.x + 1) * 4 + orientation.score
    return score.description
  }

  func solve2() -> String {
    let input = file.linesSplitByEmptyLine
    let instructions = construct(input[1][0])

    grid = input[0].map { Array($0) }
    location = Point2D(x: grid[0].firstIndex(of: ".")!, y: 0)
    orientation = Orientation.right

    for instr in instructions {
      orientation.rotate(instr)
      grid[location.y][location.x] = Array(orientation.rawValue)[0]

      if case .forward(let amount) = instr {
        move(amount: amount)
      }
    }

    print(grid.prettyDescription)
    print(location!, orientation)
    let score = (location.y + 1) * 1000 + (location.x + 1) * 4 + orientation.score
    return score.description
  }

  private func move(amount: Int) {
    switch orientation {
    case .right:
      let y = location.y
      let row = grid[y]
      var hitWall = false

      for i in 0..<amount where !hitWall {
        let x = location.x + 1

        if x >= row.count || row[x] == " " {
          nextCubeFace(x: x, y: y, orientation: orientation)
          move(amount: amount - i)
          return
        }

        switch row[x] {
        case "#":
          hitWall = true
          if i == 0 && didChangeDirection {
            location = prevLocation
            orientation = prevOrientation
          }
        default:
          grid[y][x] = ">"
          location = Point2D(x: x, y: y)
        }
      }
    case .left:
      let y = location.y
      let row = grid[y]
      var hitWall = false

      for i in 0..<amount where !hitWall{
        let x = location.x - 1

        if x < 0 || row[x] == " " {
          nextCubeFace(x: x, y: y, orientation: orientation)
          move(amount: amount - i)
          return
        }

        switch row[x] {
        case "#":
          hitWall = true
          if i == 0 && didChangeDirection {
            location = prevLocation
            orientation = prevOrientation
          }
        default:
          grid[y][x] = "<"
          location = Point2D(x: x, y: y)
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
      for i in 0..<amount where !hitWall {
        let y = location.y + 1

        if y >= col.count || col[y] == " " {
          nextCubeFace(x: x, y: y, orientation: orientation)
          move(amount: amount - i)
          return
        }

        switch col[y] {
        case "#":
          hitWall = true
          if i == 0 && didChangeDirection {
            location = prevLocation
            orientation = prevOrientation
          }
        default:
          grid[y][x] = "V"
          location = Point2D(x: x, y: y)
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
      for i in 0..<amount where !hitWall {
        let y = location.y - 1

        if y < 0 || col[y] == " " {
          nextCubeFace(x: x, y: y, orientation: orientation)
          move(amount: amount - i)
          return
        }

        switch col[y] {
        case "#":
          hitWall = true
          if i == 0 && didChangeDirection {
            location = prevLocation
            orientation = prevOrientation
          }
        default:
          grid[y][x] = "^"
          location = Point2D(x: x, y: y)
        }
      }
    }
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

  private func nextCubeFace(x: Int, y: Int, orientation o: Orientation) {
    if file.filename == "input.txt" {
      // 12
      // 3
      //45
      //6
      switch o {
      case .right:
        if y < 50 && x >= 150 { // 2R->5R
          orientation = .left
          location = Point2D(x: 100, y: 149 - y)
        } else if y < 100 && x >= 100 { // 3R->2B
          orientation = .up
          location = Point2D(x: y - 50 + 100, y: 50)
        } else if y < 150 && x >= 100 { // 5R->2R
          orientation = .left
          location = Point2D(x: 150, y: 49 - (y - 100))
        } else if y < 200 && x >= 50 { // 6R->5B
          orientation = .up
          location = Point2D(x: y - 150 + 50, y: 150)
        }
      case .left:
        if y < 50 && x < 50 { // 1L->4L
          orientation = .right
          location = Point2D(x: -1, y: 149 - y)
        } else if y < 100 && x < 50 { // 3L->4T
          orientation = .down
          location = Point2D(x: y - 50, y: 99)
        } else if y < 150 && x < 0 { // 4L->1L
          orientation = .right
          location = Point2D(x: 49, y: 49 - (y - 100))
        } else if y < 200 && x < 0 { //6L->1T
          orientation = .down
          location = Point2D(x: y - 150 + 50, y: -1)
        }
      case .down:
        if x < 50 && y >= 200 { // 6B->2T
          orientation = .down
          location = Point2D(x: x + 100, y: -1)
        } else if x < 100 && y >= 150 { //5B->6R
          orientation = .left
          location = Point2D(x: 50, y: x - 50 + 150)
        } else if x < 150 && y >= 50 { // 2B->3R
          orientation = .left
          location = Point2D(x: 100, y: x - 100 + 50)
        }
      case .up:
        if x < 50 && y < 100 { // 4T->3L
          orientation = .right
          location = Point2D(x: 49, y: x + 50)
        } else if x < 100 && y < 0 { //1T->6L
          orientation = .right
          location = Point2D(x: -1, y: x - 50 + 150)
        } else if x < 150 && y < 0 { //2T->6B
          orientation = .up
          location = Point2D(x: x - 100, y: 200)
        }
      }
    } else {
      //  1
      //234
      //  56
      switch o {
      case .right:
        if y < 4 && x >= 12 { // 1R->6R
          orientation = .left
          location = Point2D(x: 16, y: 11-y)
        } else if y < 8 && x >= 12 { // 4R->6T
          orientation = .down
          location = Point2D(x: 15 - (y - 4), y: 7)
        } else if y < 12 && x >= 16 { // 6R->1R
          orientation = .left
          location = Point2D(x: 12, y: 3 - (y-8))
        } else {
          // noop
        }
      case .left:
        if y < 4 && x < 8 { // 1L->3T
          orientation = .down
          location = Point2D(x: 4+y, y: 3)
        } else if y < 8 && x < 0 { // 2L->6B
          orientation = .up
          location = Point2D(x: 15 - (y - 4), y: 12)
        } else if y < 12 && x < 8 { // 5L->3B
          orientation = .up
          location = Point2D(x: 7 - (y - 8), y: 8)
        }
      case .down:
        if x < 4 && y >= 8 { // 2B->5B
          orientation = .up
          location = Point2D(x: 11 - x, y: 12)
        } else if x < 8 && y >= 8 { // 3B->5L
          orientation = .right
          location = Point2D(x: 7, y: 11 - (x - 4))
        } else if x < 12 && y >= 12 { // 5B->2B
          orientation = .up
          location = Point2D(x: 3 - (x - 8), y: 8)
        } else if x < 16 && y >= 12 { // 6B->2L
          orientation = .right
          location = Point2D(x: -1, y: 7 - (x - 12))
        }
      case .up:
        if x < 4 && y < 4 { // 2T->1T
          orientation = .down
          location = Point2D(x: 11 - x, y: -1)
        } else if x < 8 && y < 4 { // 3T->1L
          orientation = .right
          location = Point2D(x: 7, y: x - 4)
        } else if x < 12 && y < 0 { // 1T->2T
          orientation = .down
          location = Point2D(x: 3 - (x - 12), y: 3)
        } else if x < 16 && y < 8 { // 6T->4R
          orientation = .left
          location = Point2D(x: 12, y: 7 - (x - 16))
        }
      }
    }
    didChangeDirection = true
  }
}

