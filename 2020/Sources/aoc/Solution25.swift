class Solution25: Solving {
  let file: File
  let cardPubKey: Int
  let doorPubKey: Int

  required init(file: File) {
    self.file = file
    cardPubKey = Int(file.lines[0])!
    doorPubKey = Int(file.lines[1])!
  }

  func solve1() -> String {
    // let cardLoops = determineLoopSize(subjectNo: 7, target: cardPubKey)
    let doorLoops = determineLoopSize(subjectNo: 7, target: doorPubKey)
    // let cardEncryptKey = getKey(subjectNo: doorPubKey, loops: cardLoops)
    let doorEncryptKey = getKey(subjectNo: cardPubKey, loops: doorLoops)
    // assert(cardEncryptKey == doorEncryptKey)
    return doorEncryptKey.description
  }

  func solve2() -> String {
    return "need to solve the rest first"
  }

  func determineLoopSize(subjectNo: Int, target: Int) -> Int {
    var val = 1
    var loops = 0
    while val != target {
      loops += 1
      val = (val * subjectNo) % 20201227
    }
    return loops
  }

  func getKey(subjectNo: Int, loops: Int) -> Int {
    return (0..<loops).reduce(1) { v, _ in (v * subjectNo) % 20201227 }
  }
}
