class Solution02: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let games = file.words

    let score = games.reduce(0) {
      $0 + responseScore1($1[1]) + outcome1($1[0], $1[1])
    }

    return score.description
  }

  func solve2() -> String {
    let games = file.words

    let score = games.reduce(0) {
      $0 + responseScore2($1[1]) + outcome2($1[0], $1[1])
    }

    return score.description
  }

  private func responseScore1(_ response: String) -> Int {
    switch response {
      case "X": return 1
      case "Y": return 2
      case "Z": return 3
      default: fatalError("Unexpected input")
    }
  }

  private func outcome1(_ opp: String, _ response: String) -> Int {
    switch (opp, response) {
      case ("A", "X"), ("B", "Y"), ("C", "Z"): return 3
      case ("A", "Y"), ("B", "Z"), ("C", "X"): return 6
      case ("A", "Z"), ("B", "X"), ("C", "Y"): return 0
      default: fatalError("Unexpected input")
    }
  }

private func responseScore2(_ response: String) -> Int {
      switch response {
      case "X": return 0
      case "Y": return 3
      case "Z": return 6
      default: fatalError("Unexpected input")
    }
  }

  private func outcome2(_ opp: String, _ response: String) -> Int {
    switch (opp, response) {
      case ("A", "X"), ("B", "Z"), ("C", "Y"): return 3
      case ("A", "Y"), ("B", "X"), ("C", "Z"): return 1
      case ("A", "Z"), ("B", "Y"), ("C", "X"): return 2
      default: fatalError("Unexpected input")
    }
  }
}
