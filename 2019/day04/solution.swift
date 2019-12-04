import Foundation

// Running:
// $ ./solution.swift part [inputfilename]
// part: either `1` or `2`
// If no inputfilename provided, it takes "input.txt"

typealias Lines = [String]
typealias Words = [Lines]

class Solution {
  enum Part: Int {
    case one = 1, two
  }

  let part: Part
  let file: File

  init(part: Part, filename: String) {
    self.part = part
    file = File(filename: filename)
  }

  func get() -> String {
    switch part {
    case .one: return solveOne(file: file)
    case .two: return solveTwo(file: file)
    }
  }

  private func solveOne(file: File) -> String {
    let amount = getPasswords(lowerBound: 382345, upperBound: 843167)
    return amount.description
  }

  private func solveTwo(file: File) -> String {
    let amount = getLimitedPasswords(lowerBound: 382345, upperBound: 843167)
    return amount.description
  }

  private func getPasswords(lowerBound: Int, upperBound: Int) -> Int {
    var count = 0
    for int in lowerBound...upperBound {
      let str = int.description
      if str.isMonotoneuoslyIncreasing && str.hasDoubles {
        count += 1
      }
    }
    return count
  }

  private func getLimitedPasswords(lowerBound: Int, upperBound: Int) -> Int {
    var count = 0
    for int in lowerBound...upperBound {
      let str = int.description
      if str.isMonotoneuoslyIncreasing && str.hasLimitedDoubles {
        count += 1
      }
    }
    return count
  }
}

extension String {
  var isMonotoneuoslyIncreasing: Bool {
    var lastChar: Character = "3"
    for char in self {
      if char < lastChar {
        return false
      }
      lastChar = char
    }
    return true
  }

  var hasDoubles: Bool {
    var lastChar: Character = self[startIndex]
    for char in self[index(startIndex, offsetBy: 1)...] {
      if char == lastChar {
         return true
      }
      lastChar = char
    }

    return false
  }

  var hasLimitedDoubles: Bool {
    var hist: [Character: Int] = [:]

    for char in self {
      hist[char, default: 0] += 1
    }

    return hist.values.contains(2)
  }
}

class File {
  let filename: String

  lazy var string: String = {
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    guard let fileURL = URL(string: filename, relativeTo: currentDirectoryURL),
          let contents = try? String(contentsOf: fileURL) else {
      fatalError("file not found: \(currentDirectoryURL.path)/\(filename)")
    }

    return contents
  }()

  lazy var lines: Lines = {
    let strings = "abc"

    return string.split(separator: "\n").map(String.init)
  }()

  lazy var words: Words = {
    return lines.map { $0.split(separator: " ").map(String.init) }
  }()

  init(filename: String) {
    self.filename = filename
  }
}

let filename = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "input.txt"
let part: Solution.Part = Solution.Part(rawValue: CommandLine.arguments.count > 1 ? Int(CommandLine.arguments[1])! : 1)!
let solution = Solution(part: part, filename: filename)
let result = solution.get()

print(result)
