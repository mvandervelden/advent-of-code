class Solution04: Solving {
  let file: File

  var boards: [Words] = []
  var lastRemoved: Words? = nil

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let draws = file.lines[0].split(separator:",").map { String($0) }

    boards = Array(file.wordsByLineSplitByEmptyLine.dropFirst())

    for draw in draws {
      updateBoards(draw)
      if let winningBoard = checkBoards() {
        return score(draw, winningBoard)
      }
    }

    return boards.description
  }

  func solve2() -> String {
    let draws = file.lines[0].split(separator:",").map { String($0) }

    boards = Array(file.wordsByLineSplitByEmptyLine.dropFirst())

    for draw in draws {
      updateBoards(draw)
      checkBoards2()

      if boards.count == 0 {
        return score(draw, lastRemoved!)
      }
    }

    return boards.description
  }

  private func updateBoards(_ draw: String) {
    for b in 0..<boards.count {
      for l in 0..<boards[b].count {
        for n in 0..<boards[b][l].count {
          if boards[b][l][n] == draw {
            boards[b][l][n] = "drawn"
          }
        }
      }
    }
  }

  private func checkBoards() -> Words? {
    for board in boards {
      for line in board {
        if line.allSatisfy({ $0 == "drawn" }) { return board }
      }

      for c in 0..<board[0].count {
        var isComplete = true
        for line in board {
          if line[c] != "drawn" { isComplete = false; break }
        }
        if isComplete { return board }
      }
    }

    return nil
  }

  private func checkBoards2() {
    var newBoards: [Words] = []
    for board in boards {
      var isDone = false

      for line in board {
        if line.allSatisfy({ $0 == "drawn" }) {
          isDone = true
          break
        }
      }

      if isDone { lastRemoved = board; continue }

      for c in 0..<board[0].count {
        var isComplete = true
        for line in board {
          if line[c] != "drawn" { isComplete = false; break }
        }
        if isComplete {
          isDone = true
          break
        }
      }

      if isDone { lastRemoved = board; continue }

      newBoards.append(board)
    }

    boards = newBoards
  }


  private func score(_ draw: String, _ winning: Words) -> String {
    var sum = 0
    for line in winning {
      for val in line {
        sum += Int(val) ?? 0
      }
    }
    return (Int(draw)! * sum).description
  }
}
