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
    let pixels = file.lines[0]
    let dimensions: (x: Int, y: Int)
    if file.filename == "input.txt" {
      dimensions = (x: 25, y: 6)
    } else {
      dimensions = (x: 3, y: 2)
    }
    let imgSize = dimensions.x * dimensions.y
    let layers = pixels.chunked(into: imgSize)
    let hists: [[Character: Int]] = layers.map { layer in
      var hist: [Character: Int] = [:]

      for char in layer {
        hist[char, default: 0] += 1
      }

      return hist
    }

    let minHist = hists.min {
      ($0["0"] ?? 0) < ($1["0"] ?? 0)
    }!

    return ((minHist["1"] ?? 0) * (minHist["2"] ?? 0)).description
  }

  private func solveTwo(file: File) -> String {
   let pixels = file.lines[0]
    let dimensions: (x: Int, y: Int)
    if file.filename == "input.txt" {
      dimensions = (x: 25, y: 6)
    } else {
      dimensions = (x: 2, y: 2)
    }
    let imgSize = dimensions.x * dimensions.y
    let layers = pixels.chunked(into: imgSize)

    var result: [Character] = Array(repeating: "-", count: imgSize)

    for layer in layers {
      for ind in 0..<imgSize where result[ind] == "-" {
        let layInd = layer.index(layer.startIndex, offsetBy: ind)
        if layer[layInd] != "2" {
          result[ind] = layer[layInd]
        }
      }
    }
    let grid = result.chunked(into: dimensions.x)
    for line in grid {
      for item in line {
        print(item == "1" ? "X" : " ", terminator: " ")
      }
      print("")
    }
    return grid.description
  }
}

extension String {
  func chunked(into size: Int) -> [String] {
    var ind = startIndex
    var curCount = count
    var chunks: [String] = []
    while curCount > 0 {
      let newIndex = index(ind, offsetBy: min(size, curCount))
      let str = String(self[ind..<newIndex])
      ind = newIndex
      curCount -= size
      chunks.append(str)
    }
    return chunks
  }
}

extension Array {
  func chunked(into size: Int) -> [[Element]] {
    return stride(from: 0, to: count, by: size).map {
      Array(self[$0 ..< Swift.min($0 + size, count)])
    }
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
