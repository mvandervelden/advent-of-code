// Running:
// $ ./run.sh part [inputfilename]
// part: either `1` or `2`
// If no inputfilename provided, it takes "input.txt"

class Solution05: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {

    return file.lines.joined(separator: "\n")
  }

  func solve2() -> String {

    return file.lines.joined(separator: "\n")
  }
}
