class Solution03: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let chars = file.charsByLine
    let size = chars[0].count

    var zeros: [Int] = Array(repeatElement(0, count: size))
    var ones: [Int] = Array(repeatElement(0, count: size))
    for line in chars {
      for (i, char) in line.enumerated() {
        if char == "1" {
          ones[i] += 1
        } else {
          zeros[i] += 1
        }
      }
    }

    var gammaRateArray: [Character] = []
    var epsilonRateArray: [Character] = []
    for (zCount, oCount) in zip(zeros, ones) {
      if oCount > zCount {
        gammaRateArray.append("1")
        epsilonRateArray.append("0")
      } else {
        gammaRateArray.append("0")
        epsilonRateArray.append("1")
      }
    }

    let gamma = Int(String(gammaRateArray), radix: 2)!
    let epsilon = Int(String(epsilonRateArray), radix: 2)!


    return (gamma * epsilon).description
  }

  func solve2() -> String {
    let allNumbers = file.charsByLine

    let oxygenGeneratorRating = findRating(input: allNumbers) { $0 >= $1 }
    let co2ScrubbingRating = findRating(input: allNumbers) { $1 > $0 }

    return (oxygenGeneratorRating * co2ScrubbingRating).description
  }

  func findRating(input: [[Character]], rule: (Int, Int) -> Bool) -> Int {
    let size = input[0].count

    var remaining = input

    for i in 0..<size {
      if remaining.count == 1 {
        break
      }

      var zeros = 0
      var ones = 0
      for number in remaining {
        if number[i] == "1" {
          ones += 1
        } else {
          zeros += 1
        }
      }

      if rule(ones, zeros) {
        remaining = remaining.filter { $0[i] == "1" }
      } else {
        remaining = remaining.filter { $0[i] == "0" }
      }
    }

    print(remaining)
    return Int(String(remaining[0]), radix: 2)!
  }
}
