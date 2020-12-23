class Solution23: Solving {
  let file: File
  var circle: [Int]

  required init(file: File) {
    self.file = file
    circle = file.charsByLine[0].map { Int(String($0))! }
  }

  func solve1() -> String {
    var current = 0
    let iMax = file.filename.contains("example") ? 10 : 100
    for i in 0..<iMax {
      print("round ", i+1)
      print(circle)
      let curVal = circle[current]
      // print("current: ", curVal)
      var next = (current + 1) % circle.count
      let picksEnd = (next + 2) % circle.count
      // print("next ", next)
      // print("picksEnd ", picksEnd)
      let picks: [Int]
      if picksEnd > next {
        picks = Array(circle[next...picksEnd])
        circle.removeSubrange(next...picksEnd)
      } else {
        picks = Array(circle[next..<circle.count] + circle[0...picksEnd])
        circle.removeSubrange(next..<circle.count)
        circle.removeSubrange(0...picksEnd)
        next -= picksEnd + 1
      }
      // print("picks; ", picks.map(String.init).joined(separator: ","))
      var destination: Int? = nil
      var destVal = curVal
      while destination == nil {
        // print(destVal)
        destVal -= 1
        if destVal == 0 { destVal = 9 }
        destination = circle.firstIndex { $0 == destVal }
      }
      // print("dest: ", destVal, destination!)
      circle.insert(contentsOf: picks, at: destination! + 1)
      if destination! < next { next = (next + 3) % circle.count }
      current = next
      // print()
    }

    let oneIdx = circle.firstIndex { $0 == 1 }!
    let str = (circle[(oneIdx + 1)..<circle.count] + circle[0..<oneIdx]).map { String($0) }.joined()
    return str
  }

  func solve2() -> String {
    var current = 0
    circle += 10...1_000_000
    let iMax = 10//_000_000
    for i in 0..<iMax {
      // if i % 10_000 == 0 {
        print("round ", i+1)
      // }
      // print(circle)
      let curVal = circle[current]
      print("current: ", curVal, " idx ", current)
      var next = (current + 1) % circle.count
      let picksEnd = (next + 2) % circle.count
      // print("next ", next)
      // print("picksEnd ", picksEnd)
      let picks: [Int]
      if picksEnd > next {
        picks = Array(circle[next...picksEnd])
        circle.removeSubrange(next...picksEnd)
      } else {
        picks = Array(circle[next..<circle.count] + circle[0...picksEnd])
        circle.removeSubrange(next..<circle.count)
        circle.removeSubrange(0...picksEnd)
        next -= picksEnd + 1
      }
      print("picks; ", picks.map(String.init).joined(separator: ","))
      var destination: Int? = nil
      var destVal = curVal
      while destination == nil {
        // print(destVal)
        destVal -= 1
        if destVal == 0 { destVal = 9 }
        destination = circle.firstIndex { $0 == destVal }
      }
      print("dest: ", destVal, destination!)
      circle.insert(contentsOf: picks, at: destination! + 1)
      if destination! < next { next = (next + 3) % circle.count }
      current = next
      print()
    }
    print(file.charsByLine[0].map { Int(String($0))! })
    print(circle[0..<35])
    let oneIdx = circle.firstIndex { $0 == 1 }!
    print(circle[oneIdx..<min(oneIdx + 3, circle.count)])
    print(circle[0..<3])
    return (circle[oneIdx+1] * circle[oneIdx+2]).description
  }
}


// After 10 rounds;
//[7, 4, 9, 3, 8, 10, 12, 13, 14, 16, 17, 18, 20, 21, 22, 24, 25, 26, 28, 29, 30, 32, 33, 34, 2, 5, 6, 1, 11, 15, 19, 23, 27, 31, 35]
// so the vals after "1" arre stable for a long time, current index goes up by 4 (value as well), untiil it wraps after 1_000_000
// 10 + 249992 = 250.002 rounds, it ends with 999_999, so it wraps around:
// Round 250_002
// current [999_999]
// picks up [1_000_000, 7 ,4]
// destination [999_998] -> [..., 999_998, 1_000_000, 7, 4, 2, 5, 6, 1, 11, 15...]

// Round 250_003
// current = [7]
// picks up [4, 9, 3]
// destination [6] ->
// [7, 8, 10, 12, 13, 14, 16, ..., 999_998, 1_000_000, 7, 4, 2, 5, 6, 4, 9, 3, 1, 11, 15...]

// Round 250_004
// current = [8]
// picks up [10, 12, 13]
// dest [7] ->
// [7, 10, 12, 13, 8, 14, 16, ..., 999_998, 1_000_000, 7, 4, 2, 5, 6, 4, 9, 3, 1, 11, 15...]

// Round 250_005
// current = [14]
// picks up [16, 17, 18]
// dest [13] ->
// [7, 10, 12, 13, 16, 17, 18, 8, 10, 12, 13, 14, 20, 21, 22, 24, ..., 999_998, 1_000_000, 7, 4, 2, 5, 6, 4, 9, 3, 1, 11, 15...]

// Round 250_006
// current = [20]
// picks up [21, 22, 24]
// dest [19] ->
// [7, 10, 12, 13, 16, 17, 18, 8, 10, 12, 13, 14, 20, 25, ..., 999_998, 1_000_000, 7, 4, 2, 5, 6, 4, 9, 3, 1, 11, 15, 19, 21, 22, 24, 23, 27, 31,...]
