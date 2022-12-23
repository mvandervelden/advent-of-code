class Solution23: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  var positions: LazyGrid = [:]
  var directions: [Character] = ["N", "S", "W", "E"]

  func solve1() -> String {
    let input = file.charsByLine

    for (y, line) in input.enumerated() {
      for (x, char) in line.enumerated() {
        if char == "#" { positions[y, default: [:]][x] = "#"}
      }
    }

    for i in 0..<10 {
      print(i)
      let (proposedPositions, willMove) = proposePositions()
      if !willMove { print("DONE!"); break } // finished
      move(proposedPositions)
      directions = Array(directions[1...]) + [directions[0]]
    }

    let emptyTiles = positions.prettyDescription.split(separator: "\n").map { $0.count { $0 == "." } }.sum()
    return emptyTiles.description
  }

  func solve2() -> String {
    let input = file.charsByLine

    for (y, line) in input.enumerated() {
      for (x, char) in line.enumerated() {
        if char == "#" { positions[y, default: [:]][x] = "#"}
      }
    }

    var isDone = false
    var i = 0
    while !isDone {
      i += 1
      print(i)
      let (proposedPositions, willMove) = proposePositions()
      if !willMove { // finished
        isDone = true
        break
      }
      move(proposedPositions)
      directions = Array(directions[1...]) + [directions[0]]
    }

    return i.description
  }

  private func proposePositions() -> (newPositions: Set<Point2D>, willMove: Bool) {
    var willMove = false
    var duplicatePositions: Set<Point2D> = []
    var newPositions: [Point2D: Point2D] = [:]
    for y in positions.keys {
      for x in positions[y]!.keys {
        let pos = Point2D(x: x, y: y)
        let neighbors = pos.neighbors().filter { n in
          positions[n.y]?[n.x] != nil
        }

        if neighbors.isEmpty {
          newPositions[pos] = pos
        } else {
          willMove = true
          var newPos: Point2D?

          for dir in directions {
            if dir == "N", neighbors.first(where: { $0.y < y }) == nil {
                newPos = pos.up()
                break
            }
            if dir == "S", neighbors.first(where: { $0.y > y }) == nil {
                newPos = pos.down()
                break
            }
            if dir == "W", neighbors.first(where: { $0.x < x }) == nil {
                newPos = pos.left()
                break
            }
            if dir == "E", neighbors.first(where: { $0.x > x }) == nil {
                newPos = pos.right()
                break
            }
          }

          if let newPos {
            if duplicatePositions.contains(newPos) {
              // can't move
              newPositions[pos] = pos
            } else if let otherPos = newPositions[newPos] {
              // duplicate found
              duplicatePositions.insert(newPos)
              newPositions[newPos] = nil
              newPositions[pos] = pos
              newPositions[otherPos] = otherPos
            } else {
              // will move
              newPositions[newPos] = pos
            }
          } else {
            // no position found
            newPositions[pos] = pos
          }
        }
      }
    }
    return (newPositions: Set(newPositions.keys), willMove: willMove)
  }

  private func move(_ newPositions: Set<Point2D>) {
    var grid: LazyGrid = [:]
    for pos in newPositions { grid[pos.y, default: [:]][pos.x] = "#" }
    positions = grid
  }
}
