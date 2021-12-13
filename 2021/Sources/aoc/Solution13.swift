class Solution13: Solving {
  struct Instr: CustomStringConvertible {
    let axis: String
    let val: Int

    init(string: String) {
      let split = string.split(separator: "=")
      axis = String(split[0])
      val = Int(split[1])!
    }

    var description: String {
      return axis + "=" + val.description
    }
  }

  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let parts = file.linesSplitByEmptyLine
    let grid = parts[0].map { line in line.split(separator: ",").map { Int($0)! } }.map { Point2D(x: $0[0], y: $0[1]) }
    let instrs = parts[1].map { String($0.split(separator: " ")[2]) }.map(Instr.init)

    let result = fold(instr: instrs[0], grid: Set(grid))

    return result.count.description
  }

  func solve2() -> String {
    let parts = file.linesSplitByEmptyLine
    let grid = parts[0].map { line in line.split(separator: ",").map { Int($0)! } }.map { Point2D(x: $0[0], y: $0[1]) }
    let instrs = parts[1].map { String($0.split(separator: " ")[2]) }.map(Instr.init)

    var result = Set(grid)

    for instr in instrs {
      result = fold(instr: instr, grid: result)
    }

    printResult(result)
    return result.count.description
  }

  private func fold(instr: Instr, grid: Set<Point2D>) -> Set<Point2D> {
    let val = instr.val

    var result: Set<Point2D> = []

    if instr.axis == "x" {
      for point in grid {
        if point.x < val {
          result.insert(point)
        } else {
          let diff = point.x - val
          result.insert(Point2D(x: point.x - diff * 2, y: point.y))
        }
      }
    } else {
      for point in grid {
        if point.y < val {
          result.insert(point)
        } else {
          let diff = point.y - val
          result.insert(Point2D(x: point.x, y: point.y - diff * 2))
        }
      }
    }

    return result
  }

  private func printResult(_ result: Set<Point2D>) {
    var minX = 100
    var maxX = 0
    var minY = 100
    var maxY = 0

    for point in result {
      if point.x < minX { minX = point.x }
      if point.x > maxX { maxX = point.x }
      if point.y < minY { minY = point.y }
      if point.y > maxY { maxY = point.y }
    }

    let line = Array(repeating: Character("."), count: maxX - minX + 1)
    var grid: [[Character]] = Array(repeating: line, count: maxY - minY + 1)

    for point in result {
      grid[minY + point.y][minX + point.x] = "#"
    }

    for line in grid {
      print(String(line))
    }
  }
}
