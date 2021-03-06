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
    let fuel = file
      .lines
      .intValues
      .map(getFuel)
      .sum()
    return fuel.description
  }

  private func solveTwo(file: File) -> String {
    let fuel = file
      .lines
      .intValues
      .map(getTotalFuel)
      .sum()
    return fuel.description
  }

  private func getFuel(forMass mass: Int) -> Int {
    return max(mass / 3 - 2, 0)
  }

  private func getTotalFuel(forMass mass: Int) -> Int {
    var mass = mass
    var totalFuel = 0

    while mass > 0 {
      mass = getFuel(forMass: mass)
      totalFuel += mass
    }

    return totalFuel
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

extension Lines {
  var intValues: [Int] {
    return compactMap { Int($0) }
  }
}

extension Array where Element == Int {
  func sum() -> Int {
    return reduce(0, +)
  }
}

let filename = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "input.txt"
let part: Solution.Part = Solution.Part(rawValue: CommandLine.arguments.count > 1 ? Int(CommandLine.arguments[1])! : 1)!
let solution = Solution(part: part, filename: filename)
let result = solution.get()

print(result)
