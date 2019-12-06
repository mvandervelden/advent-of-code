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
    let input = file.words

    var orbited: [String: [String]] = [:]

    for line in input {
      orbited[line[0], default: []].append(line[1])
    }

    var orbits = 0

    for key in orbited.keys {
      orbits += calculateOrbits(orbited: orbited, key: key)
    }

    return orbits.description
  }

  private func calculateOrbits(orbited: [String: [String]], key: String) -> Int {
    var orbits = 0
    if let indirects = orbited[key] {
      orbits += indirects.count
      for ind in indirects {
        orbits += calculateOrbits(orbited: orbited, key: ind)
      }
      return orbits
    } else {
      return 0
    }
  }

  private func solveTwo(file: File) -> String {
    let input = file.words

    var orbited: [String: [String]] = [:]

    for line in input {
      orbited[line[0], default: []].append(line[1])
    }

    var youPath: [String] = []
    var currentNode = "YOU"

    while currentNode != "COM" {
      currentNode = orbited.first { $0.value.contains(currentNode) }!.key
      youPath.append(currentNode)
    }

    var sanPath: [String] = []
    currentNode = "SAN"

    while currentNode != "COM" {
      currentNode = orbited.first { $0.value.contains(currentNode) }!.key
      sanPath.append(currentNode)
    }

    var steps = 0
    for node in youPath {
      steps += 1
      if let match = sanPath.firstIndex(of: node) {
        steps += match - 1
        break
      }
    }
    // used for debugging:
    // zip(youPath.reversed(), sanPath.reversed()).forEach { youNode, sanNode in
    //   if youNode == sanNode {
    //     print("same found: \(youNode)")
    //   } else {
    //     print("different: \(youNode), \(sanNode)")
    //   }
    // }
    // print(youPath.firstIndex(of: "63K"))
    // print(sanPath.firstIndex(of: "63K"))
    return steps.description
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
    return lines.map { $0.split(separator: ")").map(String.init) }
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
