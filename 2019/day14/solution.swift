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
    return slv(file: file, requestedAmount: 1).description
  }

  private func solveTwo(file: File) -> String {
    var result = 0

    let goal = 1_000_000_000_000
    let requestedAmount = 3_061_522
    // while result < goal {
      // requestedAmount *= 2
      result = slv(file: file, requestedAmount: requestedAmount)
    // }
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return "\(formatter.string(from: requestedAmount as NSNumber)!), \(formatter.string(from: result as NSNumber)!), \(formatter.string(from: result - goal as NSNumber)!), "
  }

  private func slv(file: File, requestedAmount: Int) -> Int {
    let reactions = file.lines.map(Reaction.init)

    var elementsRequested: [String: Int] = ["FUEL": requestedAmount]
    var remainingReactions = reactions
    var oreNeeded = 0

    while !elementsRequested.isEmpty {
      print(elementsRequested)
      // select element
      let currentElement = elementsRequested.keys.first { elem in
        return !remainingReactions.contains { reaction in
          return reaction.inputs.contains { $0.elem == elem }
        }
      }!

      let currentRequestedAmount = elementsRequested[currentElement]!

      elementsRequested[currentElement] = nil

      // select reaction
      let currentReaction = remainingReactions.first { $0.output.elem == currentElement }!

      // calculate new elements/ore needed
      let multiplier = currentRequestedAmount / currentReaction.output.amount +
        (currentRequestedAmount % currentReaction.output.amount == 0 ? 0 : 1)
      for input in currentReaction.inputs {
        let amount = input.amount * multiplier
        if input.elem == "ORE" {
          oreNeeded += amount
        } else {
          elementsRequested[input.elem, default: 0] += amount
        }
      }
      // remove reaction from remaining
      remainingReactions.removeAll { $0 == currentReaction }
    }

    print(elementsRequested)
    return oreNeeded
  }
}

struct Reaction: CustomStringConvertible, Hashable {
  struct Part: Hashable {
    let elem: String
    let amount: Int
  }

  let inputs: [Part]
  let output: Part

  init(string: String) {
    let parts = string.split(separator: ">")
    let outputElems = parts.last!.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ")
    output = Part(elem: String(outputElems.last!), amount: Int(outputElems.first!)!)

    var cleanFirst = parts.first!
    cleanFirst.removeLast()
    let inputElems = cleanFirst.split(separator: ",")

    inputs = inputElems.map { elem in
      let compString = elem.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ")
      return Part(elem: String(compString.last!), amount: Int(compString.first!)!)
    }
  }

  var description: String {
    let inputsString = inputs.map { "\($0.amount) \($0.elem)" }.joined(separator: ",")
    let outputString = "\(output.amount) \(output.elem)"
    return "\(inputsString) => \(outputString)"
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
