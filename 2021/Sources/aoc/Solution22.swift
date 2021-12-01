class Solution22: Solving {
  enum Winner {
    case p1, p2
  }

  let file: File
  let player1: [Int]
  let player2: [Int]

  func gameOver(_ p1: [Int], _ p2: [Int]) -> Winner? {
    if p1.isEmpty { return .p2 }
    if p2.isEmpty { return .p1 }
    return nil
  }

  func winningScore(_ p: [Int]) -> Int {
    return p.reversed().enumerated().reduce(0) {
      $0 + ($1.offset + 1) * $1.element
    }
  }

  required init(file: File) {
    self.file = file
    let lines = file.linesSplitByEmptyLine

    player1 = lines[0]
      .dropFirst() // "Player 2:"
      .map { Int($0)! }
    player2 = lines[1]
      .dropFirst() // "Player 2:"
      .map { Int($0)! }
  }

  func solve1() -> String {
    let (_, score) = playGame(p1: player1, p2: player2)
    return score.description
  }

  func solve2() -> String {
    let (winner, score) = playRGame(p1: player1, p2: player2)
    print(winner)

    return score.description
  }

  func playGame(p1: [Int], p2: [Int]) -> (Winner, Int) {
    var p1 = p1
    var p2 = p2

    while gameOver(p1, p2) == nil {
      //print("P1: \(player1.map(String.init).joined(separator: ", "))")
      //print("P2: \(player2.map(String.init).joined(separator: ", "))")
      let c1 = p1.removeFirst()
      let c2 = p2.removeFirst()
      if c1 > c2 {
        p1.append(contentsOf: [c1, c2])
      } else {
        p2.append(contentsOf: [c2, c1])
      }
    }
    switch gameOver(p1, p2) {
    case .p1: return (.p1, winningScore(p1))
    default: return (.p2, winningScore(p2))
    }
  }

  var gameCache: [[[Int]]: (Winner, Int)] = [:]

  func playRGame(p1 orig1: [Int], p2 orig2: [Int]) -> (Winner, Int) {
    if let result = gameCache[[orig1, orig2]] { print("CACHED"); return result }

    var p1 = orig1
    var p2 = orig2
    var previousStates: [[[Int]]] = []
    while gameOver(p1, p2) == nil {
      if previousStates.contains([p1, p2]) {
        print("LOOP DETECTED!!")
        gameCache[[orig1, orig2]] = (.p1, -1)
        return (.p1, -1)
      }
      previousStates.append([p1, p2])

      if let result = gameCache[[p1, p2]] {
        print("CACHED 2")
        gameCache[[orig1, orig2]] = result
        return result
      }
      // print("P1: \(p1.map(String.init).joined(separator: ", "))")
      // print("P2: \(p2.map(String.init).joined(separator: ", "))")
      // print()
      let c1 = p1.removeFirst()
      let c2 = p2.removeFirst()

      if c1 <= p1.count && c2 <= p2.count {
        //sub-game
        print("SUBGAME!")
        let subp1 = Array(p1[0..<c1])
        let subp2 = Array(p2[0..<c2])
        let (winner, _) = playRGame(p1: subp1, p2: subp2)

        switch winner {
        case .p1: p1.append(contentsOf: [c1, c2])
        case .p2: p2.append(contentsOf: [c2, c1])
        }
      } else {
        if c1 > c2 {
          p1.append(contentsOf: [c1, c2])
        } else {
          p2.append(contentsOf: [c2, c1])
        }
      }
    }
    print("GAME OVER")
    switch gameOver(p1, p2) {
    case .p1:
      gameCache[[orig1, orig2]] = (.p1, winningScore(p1))
      return (.p1, winningScore(p1))
    default:
      gameCache[[orig1, orig2]] = (.p2, winningScore(p2))
      return (.p2, winningScore(p2))
    }
  }
}
