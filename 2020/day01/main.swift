import Foundation

enum Part: Int {
    case one = 1, two
  }

protocol Solving {
  init(file: File)

  func solve1() -> String
  func solve2() -> String
}

let filename = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "input.txt"
let file = File(filename: filename)
let part = Part(rawValue: CommandLine.arguments.count > 1 ? Int(CommandLine.arguments[1])! : 1)!
let solution = Solution(file: file)

switch part {
case .one:
  print(solution.solve1())
case .two:
  print(solution.solve2())
}
