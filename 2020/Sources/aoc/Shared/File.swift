import Foundation

typealias Lines = [String]
typealias Words = [Lines]

class File {
  let filename: String
  let day: Int

  var dayAsFolderName: String {
    return String(format: "day%02d", day)
  }

  lazy var string: String = {
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    guard let fileURL = URL(string: "Resources/aoc/\(dayAsFolderName)/\(filename)", relativeTo: currentDirectoryURL),
          let contents = try? String(contentsOf: fileURL) else {
      fatalError("file not found: \(currentDirectoryURL.path)/Resources/\(dayAsFolderName)/\(filename)")
    }

    return contents
  }()

  lazy var lines: Lines = {
    return string.split(separator: "\n").map(String.init)
  }()

  lazy var words: Words = {
    return lines.map { $0.split(separator: " ").map(String.init) }
  }()

  lazy var charsByLine: [[Character]] = {
    return lines.map { Array($0) }
  }()

lazy var linesSplitByEmptyLine: [Lines] = {
    return string.components(separatedBy: "\n\n").map { (block: String) in
      block.split(separator: "\n").map(String.init)
    }
  }()

  lazy var wordsSplitByEmptyLine: Words = {
    return string.components(separatedBy: "\n\n").map { (block: String) in
      let lines: [String.SubSequence] = block.split(separator: "\n")

      var words: [String] = []
      for line in lines {
        let wordsInLine = line.split(separator: " ")
        for word in wordsInLine {
          words.append(String(word))
        }
      }
      return words
    }
  }()

  init(day: Int, filename: String) {
    self.filename = filename
    self.day = day
  }
}
